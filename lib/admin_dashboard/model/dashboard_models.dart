import 'package:cloud_firestore/cloud_firestore.dart';

/// Holds the live counts shown on the Overview tab.
class DashboardStats {
  final int users;
  final int products;
  final int orders;
  final int alerts;
  final double totalRevenue;
  final int pendingOrders;
  final int lowStockProducts;

  const DashboardStats({
    this.users = 0,
    this.products = 0,
    this.orders = 0,
    this.alerts = 0,
    this.totalRevenue = 0,
    this.pendingOrders = 0,
    this.lowStockProducts = 0,
  });
}

class AlertItem {
  final String id;
  final String title;
  final String message;
  final String date;
  final String type;
  final Timestamp? timestamp;

  AlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    required this.timestamp,
  });

  factory AlertItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertItem(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      date: data['date'] ?? '',
      type: data['type'] ?? 'info',
      timestamp: data['timestamp'] as Timestamp?,
    );
  }
}

class TipItem {
  final String id;
  final String title;
  final String subtitle;
  final String color;
  final Timestamp? timestamp;

  TipItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.timestamp,
  });

  factory TipItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TipItem(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      color: data['color'] ?? 'teal',
      timestamp: data['timestamp'] as Timestamp?,
    );
  }
}

class ProductItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final int stock;
  final String status;
  final Timestamp? createdAt;

  ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.stock,
    required this.status,
    required this.createdAt,
  });

  bool get isLowStock => stock <= 10;

  factory ProductItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductItem(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      stock: (data['stock'] is num) ? (data['stock'] as num).toInt() : 0,
      status: data['status'] ?? 'Available',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'description': description,
    'category': category,
    'stock': stock,
    'status': status,
  };
}