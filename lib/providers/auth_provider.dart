import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentease_simple/models/user.dart';
import 'package:rentease_simple/services/firebase_service.dart';

extension IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class AuthProvider with ChangeNotifier {
  static const _currentUserKey = 'rentease_current_user';

  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  bool _initialized = false;
  final FirebaseService _firebaseService = FirebaseService();

  AuthProvider() {
    _loadFromStorage();
    _loadFromFirebase();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;
  List<User> get allUsers => List.unmodifiable(_users);
  List<User> get landlords => _users.where((u) => u.role == 'landlord').toList();
  List<User> get tenants => _users.where((u) => u.role == 'tenant').toList();

  // Load current user from SharedPreferences (local cache)
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentJson = prefs.getString(_currentUserKey);
      if (currentJson != null) {
        _currentUser = User.fromJson(json.decode(currentJson) as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error loading from storage: $e');
    }
  }

  // Load all users from Firebase
  Future<void> _loadFromFirebase() async {
    try {
      _users = await _firebaseService.getAllUsers().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Firebase load timeout - using local storage only');
          return [];
        },
      );
      print('Loaded ${_users.length} users from Firebase');
      _initialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading from Firebase (non-blocking): $e');
      _initialized = true;
      notifyListeners();
    }
  }

  // Save current user to local storage
  Future<void> _saveCurrentUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser == null) {
        await prefs.remove(_currentUserKey);
      } else {
        await prefs.setString(_currentUserKey, json.encode(_currentUser!.toJson()));
      }
    } catch (e) {
      print('Error saving current user locally: $e');
    }
  }

  String _generateInviteCode([int length = 6]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<User> registerLandlord({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      print('Registering landlord with email: $normalizedEmail');

      // Quick check in local list
      final existingLocal = _users.firstWhereOrNull(
        (u) => u.email.toLowerCase() == normalizedEmail,
      );
      if (existingLocal != null) {
        throw Exception('Email already registered');
      }

      final id = 'landlord_${DateTime.now().millisecondsSinceEpoch}';
      final code = _generateInviteCode();
      final user = User(
        id: id,
        name: name,
        email: normalizedEmail,
        phone: phone,
        role: 'landlord',
        inviteCode: code,
        isVerified: true,
        password: password,
        createdAt: DateTime.now(),
      );

      // Add to local list immediately (fast)
      _users.add(user);
      _isLoading = false;
      notifyListeners();
      
      // Save to Firebase in background (don't wait for it)
      _firebaseService.saveUser(user).catchError((e) {
        print('Background Firebase save failed: $e');
      });

      print('Landlord registered locally: ${user.email}');
      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Landlord registration error: $e');
      rethrow;
    }
  }

  Future<User> registerTenantWithCode({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String inviteCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();

      // Check landlord code if provided
      String? landlordId;
      final code = inviteCode.trim();

      if (code.isNotEmpty) {
        final codeUpper = code.toUpperCase();
        var matches = _users.where((u) => (u.inviteCode ?? '').toUpperCase() == codeUpper && u.role == 'landlord').toList();
        if (matches.isEmpty) {
          matches = _users.where((u) => u.id == code && u.role == 'landlord').toList();
        }
        if (matches.isEmpty) {
          throw Exception('Invalid invite code');
        }
        landlordId = matches.first.id;
      }

      // Quick check in local list
      final existingLocal = _users.firstWhereOrNull(
        (u) => u.email.toLowerCase() == normalizedEmail,
      );
      if (existingLocal != null) {
        throw Exception('Email already registered');
      }

      final id = 'tenant_${DateTime.now().millisecondsSinceEpoch}';
      final user = User(
        id: id,
        name: name,
        email: normalizedEmail,
        phone: phone,
        role: 'tenant',
        landlordId: landlordId,
        isVerified: true,
        password: password,
        createdAt: DateTime.now(),
      );

      // Add to local list immediately (fast)
      _users.add(user);
      
      // Save to Firebase in background (don't wait for it)
      _firebaseService.saveUser(user).catchError((e) {
        print('Background Firebase save failed: $e');
      });

      print('Tenant registered locally: ${user.email}');
      return user;
    } catch (e) {
      print('Tenant registration error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> regenerateInviteCode(String landlordId) async {
    final idx = _users.indexWhere((u) => u.id == landlordId && u.role == 'landlord');
    if (idx == -1) throw Exception('Landlord not found');

    final newCode = _generateInviteCode();
    final old = _users[idx];
    final updated = User(
      id: old.id,
      name: old.name,
      email: old.email,
      phone: old.phone,
      role: old.role,
      inviteCode: newCode,
      isVerified: old.isVerified,
      password: old.password,
      landlordId: old.landlordId,
      createdAt: old.createdAt,
    );
    _users[idx] = updated;

    // Update in Firebase
    await _firebaseService.saveUser(updated);
    notifyListeners();
    return newCode;
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();

      print('Attempting login with email: $normalizedEmail');
      print('Available users: ${_users.map((u) => '${u.email}(${u.role})').toList()}');

      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == normalizedEmail && u.password == password,
        orElse: () => throw Exception('Invalid email or password'),
      );

      _currentUser = user;
      await _saveCurrentUserLocally();
      print('✓ Login successful for: ${user.email} (${user.role})');
    } catch (e) {
      print('✗ Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUserLocally();
    notifyListeners();
  }

  // Reload users from Firebase (for sync)
  Future<void> reloadUsers() async {
    await _loadFromFirebase();
  }
}
