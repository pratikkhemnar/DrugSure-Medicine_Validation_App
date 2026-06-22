import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';

import '../drugsure_ecommerce/models/order_model.dart';
import 'model/dashboard_models.dart';

/// Every Firestore call the admin dashboard makes lives here.
/// UI widgets call into this class instead of touching
/// FirebaseFirestore directly — keeps business logic in one testable
/// place and means a Firestore schema change only touches this file.
class DashboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- Admin profile ----------

  Future<String> fetchAdminName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'Admin';
    final doc = await _db.collection('admins').doc(uid).get();
    if (doc.exists) {
      return (doc.data()?['name'] as String?) ?? 'Admin';
    }
    return 'Admin';
  }

  // ---------- Stats (Overview tab) ----------

  Future<DashboardStats> fetchStats() async {
    final usersCountFuture = _db.collection('users').count().get();
    final productsFuture = _db.collection('products').get();
    final ordersFuture = _db.collection('orders').get();
    final alertsCountFuture = _db.collection('alerts').count().get();

    final usersCount = await usersCountFuture;
    final productsSnap = await productsFuture;
    final ordersSnap = await ordersFuture;
    final alertsCount = await alertsCountFuture;

    double revenue = 0;
    int pending = 0;
    for (final doc in ordersSnap.docs) {
      try {
        final data = doc.data();
        final amount = data['totalAmount'];
        if (amount is num) revenue += amount.toDouble();
        final order = Order.fromJson({...data, 'id': doc.id});
        if (order.status == OrderStatus.pending || order.status == OrderStatus.placed) pending++;
      } catch (_) {
        // Skip malformed order documents
      }
    }

    int lowStock = 0;
    for (final doc in productsSnap.docs) {
      try {
        final data = doc.data();
        final stock = data['stock'];
        if (stock is num && stock <= 10) lowStock++;
      } catch (_) {
        // Skip malformed product documents
      }
    }

    return DashboardStats(
      users: usersCount.count ?? 0,
      products: productsSnap.docs.length,
      orders: ordersSnap.docs.length,
      alerts: alertsCount.count ?? 0,
      totalRevenue: revenue,
      pendingOrders: pending,
      lowStockProducts: lowStock,
    );
  }

  // ---------- Generic add / delete (Alerts & Tips share this shape) ----------

  Future<void> addDocument(String collection, Map<String, dynamic> data) {
    return _db.collection(collection).add(data);
  }

  Future<void> deleteDocument(String collection, String id) {
    return _db.collection(collection).doc(id).delete();
  }

  // ---------- Alerts ----------

  Stream<List<AlertItem>> watchAlerts() {
    return _db
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AlertItem.fromDoc).toList());
  }

  Future<void> addAlert({required String title, required String message, required String date}) {
    return addDocument('alerts', {
      'title': title,
      'message': message,
      'date': date,
      'type': 'info',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ---------- Tips ----------

  Stream<List<TipItem>> watchTips() {
    return _db
        .collection('tips')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TipItem.fromDoc).toList());
  }

  Future<void> addTip({required String title, required String subtitle}) {
    return addDocument('tips', {
      'title': title,
      'subtitle': subtitle,
      'color': 'teal',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ---------- Products ----------

  Stream<List<ProductItem>> watchProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProductItem.fromDoc).toList());
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    required int stock,
  }) {
    return addDocument('products', {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'stock': stock,
      'status': stock > 0 ? 'Available' : 'Out of Stock',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _db.collection('products').doc(id).update(data);
  }

  // ---------- Orders ----------

  Stream<List<Order>> watchOrders() {
    return _db
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snap) {
          final orders = <Order>[];
          for (final doc in snap.docs) {
            try {
              orders.add(Order.fromJson({...doc.data(), 'id': doc.id}));
            } catch (_) {
              // Skip malformed order documents
            }
          }
          return orders;
        });
  }

  Stream<List<Order>> watchRecentOrders({int limit = 5}) {
    return _db
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
          final orders = <Order>[];
          for (final doc in snap.docs) {
            try {
              orders.add(Order.fromJson({...doc.data(), 'id': doc.id}));
            } catch (_) {
              // Skip malformed order documents
            }
          }
          return orders;
        });
  }

  /// Human-readable notification text shown to the customer when an
  /// admin changes their order's status. Kept here (not in the model)
  /// since it's dashboard-specific copy, not a property of the order itself.
  String _notificationMessageFor(OrderStatus status, String orderId) {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Your order #$orderId has been confirmed.';
      case OrderStatus.shipped:
        return 'Your order #$orderId has been shipped!';
      case OrderStatus.outForDelivery:
        return 'Your order #$orderId is out for delivery.';
      case OrderStatus.delivered:
        return 'Your order #$orderId has been delivered. Enjoy!';
      case OrderStatus.cancelled:
        return 'Your order #$orderId has been cancelled.';
      case OrderStatus.placed:
      case OrderStatus.pending:
        return 'Your order #$orderId has been placed.';
    }
  }

  /// Updates order status AND drops a notification doc for the customer.
  /// Both writes go through a batch so they either both succeed or
  /// both fail — no "status updated but customer never notified" gap.
  Future<void> updateOrderStatus({
    required String orderDocId,
    required String orderDisplayId,
    required OrderStatus newStatus,
    String? userId,
  }) async {
    final batch = _db.batch();

    final orderRef = _db.collection('orders').doc(orderDocId);
    batch.update(orderRef, {
      'status': newStatus.displayName,
      'statusIndex': newStatus.index,
    });

    if (userId != null && userId.isNotEmpty) {
      final notifRef = _db.collection('notifications').doc();
      batch.set(notifRef, {
        'userId': userId,
        'orderId': orderDisplayId,
        'orderDocId': orderDocId,
        'title': 'Order Update',
        'message': _notificationMessageFor(newStatus, orderDisplayId),
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // ---------- Users ----------

  Stream<List<Map<String, dynamic>>> watchUsers() {
    return _db.collection('users').snapshots().map(
          (snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList(),
    );
  }
}