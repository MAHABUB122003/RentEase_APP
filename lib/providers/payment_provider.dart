import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentease_simple/models/bill.dart';
import 'package:rentease_simple/models/user.dart';
import 'package:rentease_simple/services/firebase_service.dart';
import 'package:rentease_simple/providers/auth_provider.dart';

class PaymentProvider with ChangeNotifier {
  List<Bill> _bills = [];
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _tenants = [];
  List<Map<String, dynamic>> _properties = [];
  bool _isLoading = false;
  static const _billsKey = 'rentease_bills';
  final FirebaseService _firebaseService = FirebaseService();
  late AuthProvider _authProvider;

  List<Bill> get bills => _bills;
  List<Map<String, dynamic>> get payments => _payments;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get tenants => _tenants;
  List<Map<String, dynamic>> get properties => _properties;

  PaymentProvider() {
    _loadBillsFromStorage();
    _loadBillsFromFirebase();
  }

  /// Set AuthProvider reference to get real tenants
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _updateRealTenants();
  }

  /// Update tenants list with real registered tenants
  void _updateRealTenants() {
    try {
      // Get only users with 'tenant' role
      final realTenants = _authProvider.allUsers
          .where((user) => user.role == 'tenant')
          .map((user) => {
                'id': user.id,
                'name': user.name,
                'email': user.email,
                'phone': user.phone,
                'landlordId': user.landlordId,
                'active': true,
                'monthlyRent': 15000.0,
                'notices': <Map<String, dynamic>>[],
              })
          .toList();
      
      _tenants = realTenants;
      print('Updated tenants list: ${_tenants.length} real tenants loaded');
      notifyListeners();
    } catch (e) {
      print('Error updating real tenants: $e');
    }
  }

  /// Add tenant from User (when tenant registers)
  void addTenantFromUser(User user) {
    if (user.role == 'tenant') {
      final existingIndex = _tenants.indexWhere((t) => t['id'] == user.id);
      if (existingIndex == -1) {
        _tenants.add({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'landlordId': user.landlordId,
          'active': true,
          'monthlyRent': 15000.0,
          'notices': <Map<String, dynamic>>[],
        });
        print('Tenant added: ${user.name}');
        notifyListeners();
      }
    }
  }

  // Load bills from Firebase
  Future<void> _loadBillsFromFirebase() async {
    try {
      _bills = await _firebaseService.getAllBills();
      notifyListeners();
    } catch (e) {
      print('Error loading bills from Firebase: $e');
    }
  }

  // Load bills from local storage
  Future<void> _loadBillsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final billsJson = prefs.getString(_billsKey);
      if (billsJson != null) {
        final list = jsonDecode(billsJson) as List;
        _bills = list.map((e) => Bill.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading bills from storage: $e');
    }
  }

  // Save bills to local storage
  Future<void> _saveBillsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(_bills.map((b) => b.toJson()).toList());
      await prefs.setString(_billsKey, jsonStr);
    } catch (e) {
      print('Error saving bills to storage: $e');
    }
  }

  // Create a new bill (landlord feature)
  Future<void> createBill({
    required String tenantId,
    required String landlordId,
    required double rentAmount,
    required double electricityBill,
    required double waterBill,
    required double gasBill,
    required DateTime dueDate,
  }) async {
    final totalAmount = rentAmount + electricityBill + waterBill + gasBill;
    
    final newBill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      landlordId: landlordId,
      rentAmount: rentAmount,
      electricityBill: electricityBill,
      waterBill: waterBill,
      gasBill: gasBill,
      totalAmount: totalAmount,
      dueDate: dueDate,
      billDate: DateTime.now(),
      status: 'pending',
    );

    try {
      // Save to Firebase
      await _firebaseService.saveBill(newBill);
      
      // Add to local list
      _bills.insert(0, newBill);
      _saveBillsToStorage();
      notifyListeners();
    } catch (e) {
      print('Error creating bill: $e');
      rethrow;
    }
  }

  // Make a payment for a bill
  Future<void> makePayment(String billId, String method, String transactionId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final index = _bills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      final updatedBill = Bill(
        id: _bills[index].id,
        tenantId: _bills[index].tenantId,
        landlordId: _bills[index].landlordId,
        rentAmount: _bills[index].rentAmount,
        electricityBill: _bills[index].electricityBill,
        waterBill: _bills[index].waterBill,
        gasBill: _bills[index].gasBill,
        totalAmount: _bills[index].totalAmount,
        dueDate: _bills[index].dueDate,
        billDate: _bills[index].billDate,
        status: 'paid',
        paidDate: DateTime.now(),
      );

      final payment = {
        'id': 'payment_${DateTime.now().millisecondsSinceEpoch}',
        'billId': billId,
        'tenantId': _bills[index].tenantId,
        'landlordId': _bills[index].landlordId,
        'amount': _bills[index].totalAmount,
        'date': DateTime.now(),
        'method': method,
        'status': 'success',
        'transactionId': transactionId,
      };

      _bills[index] = updatedBill;
      _payments.insert(0, payment);
      _saveBillsToStorage();

      try {
        _firebaseService.saveBill(updatedBill);
        _firebaseService.savePayment(payment);
      } catch (e) {
        print('Error saving payment: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get bills for a specific tenant
  List<Bill> getBillsForTenant(String tenantId) {
    return _bills.where((bill) => bill.tenantId == tenantId).toList();
  }

  // Get pending bills for a specific tenant
  List<Bill> getPendingBillsForTenant(String tenantId) {
    return _bills
        .where((bill) => bill.tenantId == tenantId && bill.status == 'pending')
        .toList();
  }



  // Get count of active tenants
  int getActiveTenantsCount() {
    return _tenants.where((t) => t['active'] == true).length;
  }

  // Get count of properties
  int getPropertiesCount() {
    return _properties.length;
  }

  // Get total collected amount
  double getTotalCollected() {
    return _payments.fold(0.0, (sum, p) => sum + (p['amount'] as double));
  }

  // Send a reminder to a tenant
  Future<bool> sendReminder(String tenantId, String message) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Send a message between users
  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    final msg = {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'date': DateTime.now(),
    };
    _messages.insert(0, msg);
    
    // Also save to Firebase
    try {
      await _firebaseService.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        text: text,
      );
    } catch (e) {
      print('Error saving message: $e');
    }
    
    notifyListeners();
  }

  // Get messages between two users ordered oldest first
  List<Map<String, dynamic>> getMessagesBetween(String aId, String bId) {
    final list = _messages.where((m) {
      final s = m['senderId'] as String? ?? '';
      final r = m['receiverId'] as String? ?? '';
      return (s == aId && r == bId) || (s == bId && r == aId);
    }).toList();
    // sort ascending by date (oldest first)
    list.sort((x, y) {
      final dx = x['date'] as DateTime? ?? DateTime.now();
      final dy = y['date'] as DateTime? ?? DateTime.now();
      return dx.compareTo(dy);
    });
    return list;
  }

  // Get conversation partners for a user with last message
  List<Map<String, dynamic>> getConversationsFor(String userId) {
    final partners = <String, Map<String, dynamic>>{};
    for (final m in _messages) {
      final s = m['senderId'] as String? ?? '';
      final r = m['receiverId'] as String? ?? '';
      final other = s == userId ? r : (r == userId ? s : null);
      if (other == null) continue;
      if (!partners.containsKey(other)) {
        partners[other] = m;
      }
    }
    final list = partners.entries.map((e) => {'partnerId': e.key, 'lastMessage': e.value}).toList();
    // sort by last message date descending (most recent first)
    list.sort((a, b) {
      final da = (a['lastMessage'] as Map<String, dynamic>)['date'] as DateTime? ?? DateTime.now();
      final db = (b['lastMessage'] as Map<String, dynamic>)['date'] as DateTime? ?? DateTime.now();
      return db.compareTo(da);
    });
    return list;
  }

  // Generate a report with payment statistics
  Map<String, dynamic> generateReport() {
    final totalBills = _bills.length;
    final pending = _bills.where((b) => b.status == 'pending').length;
    final paid = _bills.where((b) => b.status == 'paid').length;
    return {
      'totalBills': totalBills,
      'pending': pending,
      'paid': paid,
      'totalCollected': getTotalCollected(),
      'activeTenants': getActiveTenantsCount(),
      'properties': getPropertiesCount(),
    };
  }

  // Get all pending bills
  List<Bill> getPendingBills() {
    return _bills.where((bill) => bill.status == 'pending').toList();
  }

  // Get all paid bills
  List<Bill> getPaidBills() {
    return _bills.where((bill) => bill.status == 'paid').toList();
  }

  // Get total pending amount
  double getTotalPendingAmount() {
    return getPendingBills()
        .fold(0.0, (sum, bill) => sum + bill.totalAmount);
  }

  // Update tenant rent amount
  void updateTenantRent(String tenantId, double monthlyRent) {
    final idx = _tenants.indexWhere((t) => t['id'] == tenantId);
    if (idx != -1) {
      _tenants[idx]['monthlyRent'] = monthlyRent;
      notifyListeners();
    }
  }

  // Send a notice to a tenant (stored locally)
  void sendNoticeToTenant(String tenantId, String message) {
    final idx = _tenants.indexWhere((t) => t['id'] == tenantId);
    if (idx != -1) {
      final notice = {
        'id': 'notice_${DateTime.now().millisecondsSinceEpoch}',
        'message': message,
        'date': DateTime.now(),
        'read': false,
      };
      final notices = _tenants[idx]['notices'] as List<dynamic>? ?? [];
      notices.insert(0, notice);
      _tenants[idx]['notices'] = notices;
      notifyListeners();
    }
  }

  // Get notices for a specific tenant
  List<Map<String, dynamic>> getNoticesForTenant(String tenantId) {
    final t = _tenants.firstWhere((e) => e['id'] == tenantId, orElse: () => {});
    if (t.isEmpty) return [];
    final notices = (t['notices'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return notices;
  }

  // Get paid bills with tenant details (for landlord dashboard)
  List<Map<String, dynamic>> getPaidBillsWithTenantDetails() {
    final paidBills = getPaidBills();
    return paidBills.map((bill) {
      // Find tenant details
      final tenant = _authProvider.allUsers.firstWhere(
        (user) => user.id == bill.tenantId,
        orElse: () => User(
          id: '',
          email: '',
          name: 'Unknown Tenant',
          phone: '',
          role: 'tenant',
          createdAt: DateTime.now(),
        ),
      );
      return {
        'bill': bill,
        'tenantName': tenant.name,
        'tenantEmail': tenant.email,
        'tenantId': bill.tenantId,
        'amount': bill.totalAmount,
        'paidDate': bill.paidDate ?? DateTime.now(),
      };
    }).toList();
  }

  // Get total paid bills count
  int getTotalPaidBillsCount() {
    return getPaidBills().length;
  }

  // Get recent paid bills (last 5)
  List<Map<String, dynamic>> getRecentPaidBills() {
    final paidBillsWithDetails = getPaidBillsWithTenantDetails();
    // Sort by paid date descending
    paidBillsWithDetails.sort((a, b) => (b['paidDate'] as DateTime).compareTo(a['paidDate'] as DateTime));
    return paidBillsWithDetails.take(5).toList();
  }

  // ===== TENANT-SPECIFIC FILTERING METHODS =====

  // Get all bills for a specific tenant
  List<Bill> getBillsForTenantId(String tenantId) {
    return _bills.where((bill) => bill.tenantId == tenantId).toList();
  }

  // Get pending bills for a specific tenant
  List<Bill> getPendingBillsForTenantId(String tenantId) {
    return _bills.where((bill) => bill.tenantId == tenantId && bill.status == 'pending').toList();
  }

  // Alias for backward compatibility
  List<Bill> getPendingBillsForSpecificTenant(String tenantId) {
    return getPendingBillsForTenantId(tenantId);
  }

  // Get paid bills for a specific tenant
  List<Bill> getPaidBillsForTenantId(String tenantId) {
    return _bills.where((bill) => bill.tenantId == tenantId && bill.status == 'paid').toList();
  }

  // Alias for backward compatibility
  List<Bill> getPaidBillsForSpecificTenant(String tenantId) {
    return getPaidBillsForTenantId(tenantId);
  }

  // Get total pending amount for a specific tenant
  double getTotalPendingAmountForTenant(String tenantId) {
    return getPendingBillsForTenantId(tenantId)
        .fold(0.0, (sum, bill) => sum + bill.totalAmount);
  }

  // ===== LANDLORD-SPECIFIC FILTERING METHODS =====

  // Get all bills for a specific landlord
  List<Bill> getBillsForLandlordId(String landlordId) {
    return _bills.where((bill) => bill.landlordId == landlordId).toList();
  }

  // Alias for backward compatibility
  List<Bill> getBillsForLandlord(String landlordId) {
    return getBillsForLandlordId(landlordId);
  }

  // Get pending bills for a specific landlord
  List<Bill> getPendingBillsForLandlordId(String landlordId) {
    return _bills.where((bill) => bill.landlordId == landlordId && bill.status == 'pending').toList();
  }

  // Alias for backward compatibility
  List<Bill> getPendingBillsForLandlord(String landlordId) {
    return getPendingBillsForLandlordId(landlordId);
  }

  // Get paid bills for a specific landlord
  List<Bill> getPaidBillsForLandlordId(String landlordId) {
    return _bills.where((bill) => bill.landlordId == landlordId && bill.status == 'paid').toList();
  }

  // Get tenants for a specific landlord
  List<Map<String, dynamic>> getTenantsForLandlordId(String landlordId) {
    return _tenants
        .where((tenant) => tenant['landlordId'] == landlordId)
        .toList();
  }

  // Get active tenants count for a specific landlord
  int getActiveTenantsCountForLandlordId(String landlordId) {
    return getTenantsForLandlordId(landlordId)
        .where((tenant) => tenant['active'] == true)
        .length;
  }

  // Alias for backward compatibility
  int getActiveTenantsCountForLandlord(String landlordId) {
    return getActiveTenantsCountForLandlordId(landlordId);
  }

  // Get total collected amount for a specific landlord
  double getTotalCollectedForLandlordId(String landlordId) {
    return getPaidBillsForLandlordId(landlordId)
        .fold(0.0, (sum, bill) => sum + bill.totalAmount);
  }

  // Alias for backward compatibility
  double getTotalCollectedForLandlord(String landlordId) {
    return getTotalCollectedForLandlordId(landlordId);
  }

  // Get paid bills with tenant details for a specific landlord
  List<Map<String, dynamic>> getPaidBillsWithTenantDetailsForLandlordId(String landlordId) {
    final paidBills = getPaidBillsForLandlordId(landlordId);
    return paidBills.map((bill) {
      final tenant = _authProvider?.allUsers.firstWhere(
        (user) => user.id == bill.tenantId,
        orElse: () => User(
          id: '',
          email: '',
          name: 'Unknown Tenant',
          phone: '',
          role: 'tenant',
          createdAt: DateTime.now(),
        ),
      );
      return {
        'bill': bill,
        'tenantName': tenant?.name ?? 'Unknown',
        'tenantEmail': tenant?.email ?? 'N/A',
        'tenantId': bill.tenantId,
        'amount': bill.totalAmount,
        'paidDate': bill.paidDate ?? DateTime.now(),
      };
    }).toList();
  }

  // Get recent paid bills for a specific landlord (last 5)
  List<Map<String, dynamic>> getRecentPaidBillsForLandlordId(String landlordId) {
    final paidBillsWithDetails = getPaidBillsWithTenantDetailsForLandlordId(landlordId);
    paidBillsWithDetails.sort((a, b) => (b['paidDate'] as DateTime).compareTo(a['paidDate'] as DateTime));
    return paidBillsWithDetails.take(5).toList();
  }

  // Alias for backward compatibility
  List<Map<String, dynamic>> getRecentPaidBillsForLandlord(String landlordId) {
    return getRecentPaidBillsForLandlordId(landlordId);
  }

  // Get total paid bills count for a specific landlord
  int getTotalPaidBillsCountForLandlordId(String landlordId) {
    return getPaidBillsForLandlordId(landlordId).length;
  }

  // Alias for backward compatibility
  int getTotalPaidBillsCountForLandlord(String landlordId) {
    return getTotalPaidBillsCountForLandlordId(landlordId);
  }

  // Get total paid amount for a specific tenant
  double getTotalPaidAmountForTenant(String tenantId) {
    return getPaidBillsForTenantId(tenantId)
        .fold(0.0, (sum, bill) => sum + bill.totalAmount);
  }

  // Get paid bills with tenant details for a specific landlord
  List<Map<String, dynamic>> getPaidBillsWithTenantDetailsForLandlord(String landlordId) {
    final paidBills = getPaidBillsForLandlordId(landlordId);
    return paidBills.map((bill) {
      // Find tenant details
      final tenant = _authProvider.allUsers.firstWhere(
        (user) => user.id == bill.tenantId,
        orElse: () => User(
          id: '',
          email: '',
          name: 'Unknown Tenant',
          phone: '',
          role: 'tenant',
          createdAt: DateTime.now(),
        ),
      );
      return {
        'bill': bill,
        'tenantName': tenant.name,
        'tenantEmail': tenant.email,
        'tenantId': bill.tenantId,
        'amount': bill.totalAmount,
        'paidDate': bill.paidDate ?? DateTime.now(),
      };
    }).toList();
  }

  // Alias for backward compatibility
  List<Map<String, dynamic>> getRecentPaidBillsForLandlordAlias(String landlordId) {
    return getRecentPaidBillsForLandlordId(landlordId);
  }

  // ===== TENANT HISTORY FILTERING =====

  // Get payments for a specific tenant
  List<Map<String, dynamic>> getPaymentsForTenantId(String tenantId) {
    return _payments.where((payment) => payment['tenantId'] == tenantId).toList();
  }

  // ===== LANDLORD REPORT METHODS =====

  // Generate report for a specific landlord (only their tenants' data)
  Map<String, dynamic> generateReportForLandlord(String landlordId) {
    final billsForLandlord = getBillsForLandlord(landlordId);
    final totalBills = billsForLandlord.length;
    final pending = billsForLandlord.where((b) => b.status == 'pending').length;
    final paid = billsForLandlord.where((b) => b.status == 'paid').length;
    final activeTenants = getActiveTenantsCountForLandlordId(landlordId);
    final totalCollected = getTotalCollectedForLandlordId(landlordId);
    
    return {
      'totalBills': totalBills,
      'pending': pending,
      'paid': paid,
      'totalCollected': totalCollected,
      'activeTenants': activeTenants,
      'properties': getPropertiesCount(),
    };
  }

  // Get all bills history for a specific landlord
  List<Bill> getBillsHistoryForLandlord(String landlordId) {
    return getBillsForLandlord(landlordId);
  }

  // Get all payments history for a specific landlord
  List<Map<String, dynamic>> getPaymentsHistoryForLandlord(String landlordId) {
    final billsForLandlord = getBillsForLandlord(landlordId);
    final billIdsForLandlord = billsForLandlord.map((b) => b.id).toSet();
    return _payments.where((payment) => billIdsForLandlord.contains(payment['billId'])).toList();
  }

  // Get paid bills with tenant names for a specific landlord
  List<Map<String, dynamic>> getPaidBillsHistoryWithDetailsForLandlord(String landlordId) {
    return getPaidBillsWithTenantDetailsForLandlord(landlordId);
  }
}
