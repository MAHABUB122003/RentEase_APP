import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentease_simple/models/user.dart';

class AuthProvider with ChangeNotifier {
  static const _usersKey = 'rentease_users';
  static const _currentUserKey = 'rentease_current_user';

  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  bool _initialized = false;

  AuthProvider() {
    _loadFromStorage();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final List list = json.decode(usersJson) as List;
      _users = list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    }

    final currentJson = prefs.getString(_currentUserKey);
    if (currentJson != null) {
      _currentUser = User.fromJson(json.decode(currentJson) as Map<String, dynamic>);
      notifyListeners();
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, jsonStr);
  }

  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, json.encode(_currentUser!.toJson()));
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

    await Future.delayed(const Duration(milliseconds: 500));

    // check existing
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Email already registered');
    }

    final id = 'landlord_${DateTime.now().millisecondsSinceEpoch}';
    final code = _generateInviteCode();
    final user = User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: 'landlord',
      inviteCode: code,
      isVerified: true,
      password: password,
      createdAt: DateTime.now(),
    );

    _users.add(user);
    await _saveUsers();

    _isLoading = false;
    notifyListeners();
    return user;
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
      await Future.delayed(const Duration(milliseconds: 500));

      // allow empty invite code (tenant can register without landlord)
      String? landlordId;
      final code = inviteCode.trim();

      if (code.isNotEmpty) {
        final codeUpper = code.toUpperCase();
        // try match by inviteCode (case-insensitive) for landlords
        var matches = _users.where((u) => (u.inviteCode ?? '').toUpperCase() == codeUpper && u.role == 'landlord').toList();
        // also allow using landlord id directly (user may paste id instead of code)
        if (matches.isEmpty) {
          matches = _users.where((u) => u.id == code && u.role == 'landlord').toList();
        }
        if (matches.isEmpty) {
          throw Exception('Invalid invite code');
        }
        landlordId = matches.first.id;
      }

      if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
        throw Exception('Email already registered');
      }

      final id = 'tenant_${DateTime.now().millisecondsSinceEpoch}';
      final user = User(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: 'tenant',
        landlordId: landlordId,
        isVerified: true,
        password: password,
        createdAt: DateTime.now(),
      );

      _users.add(user);
      await _saveUsers();

      return user;
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
    await _saveUsers();
    notifyListeners();
    return newCode;
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );

      _currentUser = user;
      await _saveCurrentUser();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUser();
    notifyListeners();
  }

  List<User> get allUsers => List.unmodifiable(_users);
  List<User> get landlords => _users.where((u) => u.role == 'landlord').toList();
  List<User> get tenants => _users.where((u) => u.role == 'tenant').toList();
  bool get initialized => _initialized;
}