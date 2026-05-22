// ============================================================
// FILE: providers/cart_provider.dart
// ============================================================
// 
// HOW TO SETUP:
// 1. Add 'provider' package in pubspec.yaml
// 2. Wrap your MaterialApp with MultiProvider in main.dart:
//
//    MultiProvider(
//      providers: [
//        ChangeNotifierProvider(create: (_) => CartProvider()),
//        ChangeNotifierProvider(create: (_) => WishlistProvider()),
//      ],
//      child: MaterialApp(...)
//    )
// ============================================================

import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';
import '../models/order_model.dart';

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});

  double get totalPrice => medicine.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalSavings => _items.fold(
      0.0, (sum, item) => sum + ((item.medicine.mrp - item.medicine.price) * item.quantity));

  double get deliveryCharge => subtotal > 499 ? 0.0 : 40.0;

  double get total => subtotal + deliveryCharge;

  bool isInCart(String medicineId) =>
      _items.any((item) => item.medicine.id == medicineId);

  int getQuantity(String medicineId) {
    final item = _items.firstWhere(
      (item) => item.medicine.id == medicineId,
      orElse: () => CartItem(medicine: Medicine(
        id: '', name: '', brand: '', description: '', price: 0,
        mrp: 0, discountPercent: 0, imageUrl: '', category: '',
        composition: '', manufacturer: '', requiresPrescription: false,
        inStock: false, stockCount: 0, rating: 0, reviewCount: 0,
        uses: [], sideEffects: [], dosage: '', packSize: '',
      )),
    );
    return item.medicine.id.isEmpty ? 0 : item.quantity;
  }

  void addItem(Medicine medicine) {
    final existingIndex =
        _items.indexWhere((item) => item.medicine.id == medicine.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(medicine: medicine));
    }
    notifyListeners();
  }

  void removeItem(String medicineId) {
    _items.removeWhere((item) => item.medicine.id == medicineId);
    notifyListeners();
  }

  void decreaseQuantity(String medicineId) {
    final index = _items.indexWhere((item) => item.medicine.id == medicineId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void increaseQuantity(String medicineId) {
    final index = _items.indexWhere((item) => item.medicine.id == medicineId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// ============================================================
// FILE: providers/wishlist_provider.dart  
// ============================================================

class WishlistProvider extends ChangeNotifier {
  final List<Medicine> _items = [];

  List<Medicine> get items => List.unmodifiable(_items);

  bool isWishlisted(String medicineId) =>
      _items.any((m) => m.id == medicineId);

  void toggle(Medicine medicine) {
    if (isWishlisted(medicine.id)) {
      _items.removeWhere((m) => m.id == medicine.id);
    } else {
      _items.add(medicine);
    }
    notifyListeners();
  }
}
