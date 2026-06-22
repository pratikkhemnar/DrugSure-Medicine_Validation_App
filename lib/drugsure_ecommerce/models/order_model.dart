// ============================================================
// FILE: models/cart_model.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'medicine_model.dart';

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});

  double get totalPrice => medicine.price * quantity;

  Map<String, dynamic> toJson() => {
    'medicine': medicine.toJson(),
    'quantity': quantity,
  };
}

// ============================================================
// FILE: models/address_model.dart
// ============================================================

class Address {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String addressType; // 'Home', 'Work', 'Other'
  final bool isDefault;

  Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.addressType = 'Home',
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] ?? '',
    fullName: json['fullName'] ?? '',
    phone: json['phone'] ?? '',
    addressLine1: json['addressLine1'] ?? '',
    addressLine2: json['addressLine2'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    pincode: json['pincode'] ?? '',
    addressType: json['addressType'] ?? 'Home',
    isDefault: json['isDefault'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'city': city,
    'state': state,
    'pincode': pincode,
    'addressType': addressType,
    'isDefault': isDefault,
  };

  String get displayAddress =>
      '$addressLine1${addressLine2.isNotEmpty ? ', $addressLine2' : ''}, $city, $state - $pincode';
}

// ============================================================
// FILE: models/order_model.dart
// ============================================================

class OrderItem {
  final String medicineId;
  final String medicineName;
  final String medicineBrand;
  final double price;
  final int quantity;
  final double totalPrice;

  OrderItem({
    required this.medicineId,
    required this.medicineName,
    required this.medicineBrand,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    medicineId: json['medicineId'] ?? '',
    medicineName: json['medicineName'] ?? json['name'] ?? '',
    medicineBrand: json['medicineBrand'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    quantity: json['quantity'] ?? 1,
    totalPrice: (json['totalPrice'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'medicineId': medicineId,
    'medicineName': medicineName,
    'medicineBrand': medicineBrand,
    'price': price,
    'quantity': quantity,
    'totalPrice': totalPrice,
    'name': medicineName, // For Admin Dashboard list rendering compatibility
  };
}

enum OrderStatus { placed, confirmed, shipped, outForDelivery, delivered, cancelled, pending }

extension OrderStatusExt on OrderStatus {
  /// Plain getter — NOT async. A getter that returns a value the UI needs
  /// immediately (e.g. inside `Text(order.status.displayName)`) must be
  /// synchronous; returning a Future here would make every call site need
  /// `.then()` or `await`, and `Text()` can't render a Future at all.
  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.pending:
        return 'Pending';
    }
  }

  /// Used to drive progress trackers (e.g. a 5-step delivery tracker UI).
  /// `pending` and `placed` are treated as the same starting point (0) so
  /// legacy orders saved before `pending` existed still track correctly.
  /// `cancelled` returns -1 as a sentinel meaning "not on the happy path".
  int get stepIndex {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.placed:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final Address deliveryAddress;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double total;
  final String paymentMethod;
  final String paymentId; // Razorpay payment ID
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.total,
    required this.paymentMethod,
    this.paymentId = '',
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
  });

  static OrderStatus _parseStatus(Map<String, dynamic> json) {
    if (json['status'] != null) {
      final statusStr = json['status'].toString().toLowerCase();
      switch (statusStr) {
        case 'pending':
          return OrderStatus.pending;
        case 'placed':
        case 'order placed':
          return OrderStatus.placed;
        case 'processing':
        case 'confirmed':
          return OrderStatus.confirmed;
        case 'shipped':
          return OrderStatus.shipped;
        case 'out for delivery':
        case 'outfordelivery':
          return OrderStatus.outForDelivery;
        case 'delivered':
          return OrderStatus.delivered;
        case 'cancelled':
          return OrderStatus.cancelled;
      }
    }
    if (json['statusIndex'] is int) {
      final idx = json['statusIndex'] as int;
      if (idx >= 0 && idx < OrderStatus.values.length) {
        return OrderStatus.values[idx];
      }
    }
    return OrderStatus.placed;
  }

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] ?? json['orderId'] ?? '',
    userId: json['userId'] ?? '',
    items: (json['items'] as List? ?? [])
        .map((i) => OrderItem.fromJson(i))
        .toList(),
    deliveryAddress: Address.fromJson(json['deliveryAddress'] ?? {}),
    subtotal: (json['subtotal'] ?? json['totalAmount'] ?? 0).toDouble(),
    discount: (json['discount'] ?? 0).toDouble(),
    deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
    total: (json['total'] ?? json['totalAmount'] ?? 0).toDouble(),
    paymentMethod: json['paymentMethod'] ?? '',
    paymentId: json['paymentId'] ?? '',
    status: _parseStatus(json),
    createdAt: _parseDate(json['orderDate']) ?? _parseDate(json['createdAt']) ?? DateTime.now(),
    estimatedDelivery: _parseDate(json['estimatedDelivery']),
  );

  /// Safely parses any date value Firestore might store:
  /// – [Timestamp] objects (standard Firestore date fields)
  /// – ISO 8601 strings  (e.g. stored by toJson())
  /// Returns null if the value is null or cannot be parsed.
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try { return DateTime.parse(value); } catch (_) { return null; }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': id, // Admin and profile dashboard compatibility
    'userId': userId,
    'items': items.map((i) => i.toJson()).toList(),
    'deliveryAddress': deliveryAddress.toJson(),
    'shippingAddress': {
      'address': deliveryAddress.displayAddress,
    }, // Admin Dashboard compatibility
    'subtotal': subtotal,
    'discount': discount,
    'deliveryCharge': deliveryCharge,
    'total': total,
    'totalAmount': total, // Admin and profile dashboard compatibility
    'paymentMethod': paymentMethod,
    'paymentId': paymentId,
    'statusIndex': status.index,
    'status': status.displayName, // Admin and profile dashboard compatibility
    'createdAt': createdAt.toIso8601String(),
    'orderDate': Timestamp.fromDate(createdAt), // Admin and profile dashboard sorting
    'estimatedDelivery': estimatedDelivery?.toIso8601String(),
  };
}