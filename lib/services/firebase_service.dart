import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentease_simple/models/bill.dart';
import 'package:rentease_simple/models/user.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Collections
  static const String usersCollection = 'users';
  static const String billsCollection = 'bills';
  static const String paymentsCollection = 'payments';
  static const String messagesCollection = 'messages';

  // ============ USER OPERATIONS ============

  /// Save user to Firestore
  Future<void> saveUser(User user) async {
    try {
      print('Firebase: Saving user ${user.email}...');
      await _firestore.collection(usersCollection).doc(user.id).set(
            user.toJson(),
            SetOptions(merge: true),
          );
      print('Firebase: User saved successfully');
    } catch (e) {
      print('Firebase save error (non-blocking): $e');
      // Don't rethrow - let it fail silently in background
    }
  }

  /// Get user by ID
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      print('Firestore: Querying user by email: $email');
      final query = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      print('Firestore: Query returned ${query.docs.length} results');
      if (query.docs.isNotEmpty) {
        final user = User.fromJson(query.docs.first.data() as Map<String, dynamic>);
        print('Firestore: Found user: ${user.email}');
        return user;
      }
      print('Firestore: No user found for email: $email');
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final query = await _firestore.collection(usersCollection).get();
      return query.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  /// Get all tenants
  Future<List<User>> getAllTenants() async {
    try {
      final query = await _firestore
          .collection(usersCollection)
          .where('role', isEqualTo: 'tenant')
          .get();
      return query.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting tenants: $e');
      return [];
    }
  }

  /// Get all landlords
  Future<List<User>> getAllLandlords() async {
    try {
      final query = await _firestore
          .collection(usersCollection)
          .where('role', isEqualTo: 'landlord')
          .get();
      return query.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting landlords: $e');
      return [];
    }
  }

  // ============ BILL OPERATIONS ============

  /// Save/create a bill
  Future<void> saveBill(Bill bill) async {
    try {
      await _firestore.collection(billsCollection).doc(bill.id).set(
            bill.toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error saving bill: $e');
      rethrow;
    }
  }

  /// Get bill by ID
  Future<Bill?> getBill(String billId) async {
    try {
      final doc = await _firestore.collection(billsCollection).doc(billId).get();
      if (doc.exists) {
        return Bill.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting bill: $e');
      return null;
    }
  }

  /// Get all bills for a tenant
  Future<List<Bill>> getBillsForTenant(String tenantId) async {
    try {
      final query = await _firestore
          .collection(billsCollection)
          .where('tenantId', isEqualTo: tenantId)
          .orderBy('billDate', descending: true)
          .get();
      return query.docs
          .map((doc) => Bill.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting tenant bills: $e');
      return [];
    }
  }

  /// Get pending bills for a tenant
  Future<List<Bill>> getPendingBillsForTenant(String tenantId) async {
    try {
      final query = await _firestore
          .collection(billsCollection)
          .where('tenantId', isEqualTo: tenantId)
          .where('status', isEqualTo: 'pending')
          .orderBy('dueDate')
          .get();
      return query.docs
          .map((doc) => Bill.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting pending bills: $e');
      return [];
    }
  }

  /// Get all bills for a landlord
  Future<List<Bill>> getBillsForLandlord(String landlordId) async {
    try {
      final query = await _firestore
          .collection(billsCollection)
          .where('landlordId', isEqualTo: landlordId)
          .orderBy('billDate', descending: true)
          .get();
      return query.docs
          .map((doc) => Bill.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting landlord bills: $e');
      return [];
    }
  }

  /// Get all bills
  Future<List<Bill>> getAllBills() async {
    try {
      final query = await _firestore
          .collection(billsCollection)
          .orderBy('billDate', descending: true)
          .get();
      return query.docs
          .map((doc) => Bill.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all bills: $e');
      return [];
    }
  }

  // ============ PAYMENT OPERATIONS ============

  /// Save payment
  Future<void> savePayment(Map<String, dynamic> payment) async {
    try {
      final paymentId = payment['id'] ?? 'payment_${DateTime.now().millisecondsSinceEpoch}';
      await _firestore.collection(paymentsCollection).doc(paymentId).set(
            payment,
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error saving payment: $e');
      rethrow;
    }
  }

  /// Get payments for a bill
  Future<List<Map<String, dynamic>>> getPaymentsForBill(String billId) async {
    try {
      final query = await _firestore
          .collection(paymentsCollection)
          .where('billId', isEqualTo: billId)
          .orderBy('date', descending: true)
          .get();
      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting payments: $e');
      return [];
    }
  }

  // ============ MESSAGE OPERATIONS ============

  /// Send message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    try {
      final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
      await _firestore.collection(messagesCollection).doc(messageId).set({
        'id': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'date': DateTime.now(),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Get messages between two users
  Future<List<Map<String, dynamic>>> getMessagesBetween(String userId1, String userId2) async {
    try {
      final query = await _firestore
          .collection(messagesCollection)
          .where('senderId', whereIn: [userId1, userId2])
          .where('receiverId', whereIn: [userId1, userId2])
          .orderBy('date', descending: false)
          .get();
      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  /// Stream messages between two users (real-time)
  Stream<List<Map<String, dynamic>>> streamMessagesBetween(String userId1, String userId2) {
    try {
      return _firestore
          .collection(messagesCollection)
          .where('senderId', whereIn: [userId1, userId2])
          .where('receiverId', whereIn: [userId1, userId2])
          .orderBy('date', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming messages: $e');
      return Stream.value([]);
    }
  }

  // ============ REAL-TIME STREAMS ============

  /// Stream bills for tenant (real-time updates)
  Stream<List<Bill>> streamBillsForTenant(String tenantId) {
    try {
      return _firestore
          .collection(billsCollection)
          .where('tenantId', isEqualTo: tenantId)
          .orderBy('billDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Bill.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      print('Error streaming bills: $e');
      return Stream.value([]);
    }
  }

  /// Stream all bills for landlord (real-time updates)
  Stream<List<Bill>> streamBillsForLandlord(String landlordId) {
    try {
      return _firestore
          .collection(billsCollection)
          .where('landlordId', isEqualTo: landlordId)
          .orderBy('billDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Bill.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      print('Error streaming landlord bills: $e');
      return Stream.value([]);
    }
  }

  // ============ DELETE OPERATIONS ============

  /// Delete a bill
  Future<void> deleteBill(String billId) async {
    try {
      await _firestore.collection(billsCollection).doc(billId).delete();
    } catch (e) {
      print('Error deleting bill: $e');
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
