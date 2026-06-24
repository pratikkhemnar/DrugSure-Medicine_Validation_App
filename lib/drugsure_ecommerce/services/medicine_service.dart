// ============================================================
// FILE: services/medicine_service.dart
// ============================================================
//
// API INTEGRATION POINTS:
// 1. Firebase Firestore (primary - recommended for DrugSure)
// 2. REST API option also provided
//
// pubspec.yaml dependencies needed:
//   cloud_firestore: ^4.x.x
//   firebase_core: ^2.x.x
//   http: ^1.x.x             (for REST API)
//   razorpay_flutter: ^1.x.x  (for payment)
//   shared_preferences: ^2.x.x
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/cupertino.dart';
import '../models/medicine_model.dart';
import '../models/order_model.dart';

// ============================================================
// MEDICINE SERVICE
// ============================================================

class MedicineService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---- CHANGE THIS: Firestore collection name ----
  static const String _collection = 'medicines';

  /// Fetch all medicines
  /// TODO: Replace dummy data with real Firestore fetch
  Future<List<Medicine>> getAllMedicines() async {
    // OPTION 1: Firestore (uncomment when ready)
    // try {
    //   final snapshot = await _db.collection(_collection).get();
    //   return snapshot.docs.map((doc) {
    //     final data = doc.data();
    //     data['id'] = doc.id;
    //     return Medicine.fromJson(data);
    //   }).toList();
    // } catch (e) {
    //   throw Exception('Failed to fetch medicines: $e');
    // }

    // OPTION 2: REST API (uncomment when ready)
    // final response = await http.get(Uri.parse('YOUR_API_BASE_URL/medicines'));
    // if (response.statusCode == 200) {
    //   final List data = jsonDecode(response.body);
    //   return data.map((m) => Medicine.fromJson(m)).toList();
    // }
    // throw Exception('API Error: ${response.statusCode}');

    // Using dummy data for now
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network
    return getDummyMedicines();
  }

  /// Search medicines by name, brand, or composition
  Future<List<Medicine>> searchMedicines(String query) async {
    // OPTION 1: Firestore
    // final snapshot = await _db.collection(_collection)
    //     .where('searchTokens', arrayContains: query.toLowerCase())
    //     .limit(20)
    //     .get();

    // OPTION 2: REST API
    // GET YOUR_API_BASE_URL/medicines/search?q=query

    await Future.delayed(const Duration(milliseconds: 400));
    final all = getDummyMedicines();
    final q = query.toLowerCase();
    return all.where((m) =>
        m.name.toLowerCase().contains(q) ||
        m.brand.toLowerCase().contains(q) ||
        m.composition.toLowerCase().contains(q) ||
        m.category.toLowerCase().contains(q)).toList();
  }

  /// Fetch medicines by category
  Future<List<Medicine>> getMedicinesByCategory(String category) async {
    // Firestore: await _db.collection(_collection).where('category', isEqualTo: category).get()
    // REST: GET YOUR_API_BASE_URL/medicines?category=category
    await Future.delayed(const Duration(milliseconds: 500));
    return getDummyMedicines().where((m) => m.category == category).toList();
  }

  /// Fetch single medicine by ID
  Future<Medicine?> getMedicineById(String id) async {
    // Firestore: await _db.collection(_collection).doc(id).get()
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return getDummyMedicines().firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ============================================================
// ORDER SERVICE
// ============================================================

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';
  static const String _usersCollection = 'users';

  /// Place a new order
  /// TODO: Connect to your Firestore and Razorpay
  Future<Order> placeOrder({
    required String userId,
    required List<CartItem> cartItems,
    required Address deliveryAddress,
    required String paymentMethod,
    String paymentId = '',
    required double subtotal,
    required double discount,
    required double deliveryCharge,
    required    double total,
  }) async {
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final order = Order(
      id: orderId,
      userId: userId,
      items: cartItems.map((ci) => OrderItem(
        medicineId: ci.medicine.id,
        medicineName: ci.medicine.name,
        medicineBrand: ci.medicine.brand,
        price: ci.medicine.price,
        quantity: ci.quantity,
        totalPrice: ci.totalPrice,
      )).toList(),
      deliveryAddress: deliveryAddress,
      subtotal: subtotal,
      discount: discount,
      deliveryCharge: deliveryCharge,
      total: total,
      paymentMethod: paymentMethod,
      paymentId: paymentId,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
    );

    // SAVE TO FIRESTORE
    try {
      await _db.collection(_ordersCollection).doc(orderId).set(order.toJson());
      // Also update user's order history
      await _db.collection(_usersCollection).doc(userId)
          .collection('orders').doc(orderId).set({
            'orderId': orderId, 
            'createdAt': Timestamp.fromDate(order.createdAt),
          });
    } catch (e) {
      debugPrint("Error writing order to Firestore: $e");
    }

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return order;
  }

  /// Get all orders for a user
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      // No .orderBy() to avoid composite index requirement — sort client-side.
      final snapshot = await _db.collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final orders = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return Order.fromJson(data);
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      }
    } catch (e) {
      debugPrint("Error fetching user orders: $e");
    }
    return [];
  }

  List<Order> _getDummyOrders(String userId) {
    final dummyAddress = Address(
      id: 'addr1',
      fullName: 'Pratik Khemnar',
      phone: '9876543210',
      addressLine1: 'Flat 204, Shree Ganesh Apts',
      addressLine2: 'Near KJ College',
      city: 'Pune',
      state: 'Maharashtra',
      pincode: '411048',
    );

    return [
      Order(
        id: 'ORD1716000001',
        userId: userId,
        items: [
          OrderItem(medicineId: 'm1', medicineName: 'Paracetamol 500mg',
              medicineBrand: 'Calpol', price: 18.0, quantity: 2, totalPrice: 36.0),
          OrderItem(medicineId: 'm3', medicineName: 'Cetirizine 10mg',
              medicineBrand: 'Cetzine', price: 28.0, quantity: 1, totalPrice: 28.0),
        ],
        deliveryAddress: dummyAddress,
        subtotal: 64.0, discount: 0.0, deliveryCharge: 40.0, total: 104.0,
        paymentMethod: 'UPI',
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Order(
        id: 'ORD1716000002',
        userId: userId,
        items: [
          OrderItem(medicineId: 'm5', medicineName: 'Vitamin D3 60000 IU',
              medicineBrand: 'D-Rise', price: 75.0, quantity: 1, totalPrice: 75.0),
        ],
        deliveryAddress: dummyAddress,
        subtotal: 75.0, discount: 0.0, deliveryCharge: 40.0, total: 115.0,
        paymentMethod: 'Card',
        status: OrderStatus.shipped,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
      ),
    ];
  }
}

// ============================================================
// ADDRESS SERVICE
// ============================================================

class AddressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Address>> getUserAddresses(String userId) async {
    // FIRESTORE:
    // final snapshot = await _db.collection('users').doc(userId)
    //     .collection('addresses').get();
    // return snapshot.docs.map((doc) => Address.fromJson(doc.data())).toList();

    await Future.delayed(const Duration(milliseconds: 300));
    return []; // return empty initially, user will add
  }

  Future<void> saveAddress(String userId, Address address) async {
    // FIRESTORE:
    // await _db.collection('users').doc(userId)
    //     .collection('addresses').doc(address.id).set(address.toJson());

    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    // FIRESTORE:
    // await _db.collection('users').doc(userId)
    //     .collection('addresses').doc(addressId).delete();
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
