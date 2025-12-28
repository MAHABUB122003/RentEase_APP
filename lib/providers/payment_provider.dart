import 'package:flutter/material.dart';
import 'package:rentease_simple/models/bill.dart';
import 'package:rentease_simple/models/user.dart';

class PaymentProvider with ChangeNotifier {
  List<Bill> _bills = [];
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _tenants = [];
  List<Map<String, dynamic>> _properties = [];
  bool _isLoading = false;

  List<Bill> get bills => _bills;
  List<Map<String, dynamic>> get payments => _payments;
  bool get isLoading => _isLoading;

  PaymentProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _bills = [
      Bill(
        id: '1',
        tenantId: 'tenant_1',
        landlordId: 'landlord_1',
        rentAmount: 15000,
        electricityBill: 1200,
        waterBill: 500,
        gasBill: 800,
        totalAmount: 17500,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        billDate: DateTime.now().subtract(const Duration(days: 25)),
        status: 'pending',
      ),
      Bill(
        id: '2',
        tenantId: 'tenant_1',
        landlordId: 'landlord_1',
        rentAmount: 15000,
        electricityBill: 1000,
        waterBill: 450,
        gasBill: 750,
        totalAmount: 17200,
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        billDate: DateTime.now().subtract(const Duration(days: 55)),
        status: 'paid',
      ),
    ];

    _payments = [
      {
        'id': 'payment_1',
        'billId': '2',
        'amount': 17200,
        'date': DateTime.now().subtract(const Duration(days: 35)),
        'method': 'bkash',
        'status': 'success',
        'transactionId': 'TX123456',
      }
    ];

    _tenants = [
      {
        'id': 'tenant_1',
        'name': 'Rafiq Ahmed',
        'email': 'rafiq@example.com',
        'phone': '01700000001',
        'propertyId': 'prop_1',
        'active': true,
        'monthlyRent': 15000.0,
        'notices': <Map<String, dynamic>>[],
      },
      {
        'id': 'tenant_2',
        'name': 'Salma Begum',
        'email': 'salma@example.com',
        'phone': '01700000002',
        'propertyId': 'prop_2',
        'active': true,
        'monthlyRent': 12000.0,
        'notices': <Map<String, dynamic>>[],
      },
    ];

    _properties = [
      {
        'id': 'prop_1',
        'name': 'Green Apartments',
        'address': 'Mirpur, Dhaka',
      },
      {
        'id': 'prop_2',
        'name': 'Lake View',
        'address': 'Gulshan, Dhaka',
      },
    ];
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

  List<Map<String, dynamic>> getNoticesForTenant(String tenantId) {
    final t = _tenants.firstWhere((e) => e['id'] == tenantId, orElse: () => {});
    if (t.isEmpty) return [];
    final notices = (t['notices'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return notices;
  }

  Future<void> makePayment(String billId, String method, String transactionId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final index = _bills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      _bills[index] = Bill(
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
      );

      _payments.insert(0, {
        'id': 'payment_${DateTime.now().millisecondsSinceEpoch}',
        'billId': billId,
        'amount': _bills[index].totalAmount,
        'date': DateTime.now(),
        'method': method,
        'transactionId': transactionId,
        'status': 'success',
      });
    }

    _isLoading = false;
    notifyListeners();
  }

  // Tenants & properties helpers
  List<Map<String, dynamic>> get tenants => _tenants;

  List<Map<String, dynamic>> get properties => _properties;

  int getActiveTenantsCount() {
    return _tenants.where((t) => t['active'] == true).length;
  }

  int getPropertiesCount() {
    return _properties.length;
  }

  double getTotalCollected() {
    return _payments.fold(0.0, (sum, p) => sum + (p['amount'] as double));
  }

  // Send a mock reminder to a tenant (returns true on success)
  Future<bool> sendReminder(String tenantId, String message) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    return true;
  }

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

  List<Bill> getPendingBills() {
    return _bills.where((bill) => bill.status == 'pending').toList();
  }

  // ADD THIS METHOD
  List<Bill> getPaidBills() {
    return _bills.where((bill) => bill.status == 'paid').toList();
  }

  double getTotalPendingAmount() {
    return getPendingBills()
        .fold(0.0, (sum, bill) => sum + bill.totalAmount);
  }

  // ADD THIS METHOD
  void createBill({
    required String tenantId,
    required double rentAmount,
    required double electricityBill,
    required double waterBill,
    required double gasBill,
    required DateTime dueDate,
  }) {
    final totalAmount = rentAmount + electricityBill + waterBill + gasBill;
    
    final newBill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      landlordId: 'landlord_1',
      rentAmount: rentAmount,
      electricityBill: electricityBill,
      waterBill: waterBill,
      gasBill: gasBill,
      totalAmount: totalAmount,
      dueDate: dueDate,
      billDate: DateTime.now(),
      status: 'pending',
    );

    _bills.insert(0, newBill);
    notifyListeners();
  }

  // Add a tenant record when a user registers as tenant
  void addTenantFromUser(User user, {String? propertyId}) {
    // avoid duplicates
    if (_tenants.any((t) => t['id'] == user.id)) return;

    _tenants.insert(0, {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'propertyId': propertyId ?? '',
      'active': true,
    });
    notifyListeners();
  }
}