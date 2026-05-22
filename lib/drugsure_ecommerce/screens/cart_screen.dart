// ============================================================
// FILE: screens/cart_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: Text('Cart (${cart.itemCount} items)',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _showClearCartDialog(context, cart),
              child: const Text('Clear', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => _buildCartItem(context, cart, i),
                  ),
                ),
                _buildOrderSummary(context, cart),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 70, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 24),
          const Text('Your cart is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add medicines to get started',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Browse Medicines',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartProvider cart, int index) {
    final item = cart.items[index];
    final med = item.medicine;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: med.imageUrl.startsWith('http')
                ? Image.network(med.imageUrl, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.medication, color: Color(0xFF1565C0)))
                : const Icon(Icons.medication, color: Color(0xFF1565C0), size: 36),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(med.packSize,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('₹${med.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 15, color: Color(0xFF1565C0))),
                    const SizedBox(width: 6),
                    Text('₹${med.mrp.toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12,
                            decoration: TextDecoration.lineThrough)),
                  ],
                ),
              ],
            ),
          ),

          // Quantity controls
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1565C0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => cart.decreaseQuantity(med.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.remove, size: 16, color: Color(0xFF1565C0)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0))),
                    ),
                    GestureDetector(
                      onTap: () => cart.increaseQuantity(med.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.add, size: 16, color: Color(0xFF1565C0)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => cart.removeItem(med.id),
                child: Text('Remove',
                    style: TextStyle(color: Colors.red[400], fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
          _summaryRow('Delivery',
              cart.deliveryCharge == 0 ? 'FREE' : '₹${cart.deliveryCharge.toStringAsFixed(2)}',
              valueColor: cart.deliveryCharge == 0 ? Colors.green : null),
          _summaryRow('You Save', '-₹${cart.totalSavings.toStringAsFixed(2)}',
              valueColor: Colors.green),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('₹${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 18, color: Color(0xFF1565C0))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen())),
              child: const Text('Proceed to Checkout',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          if (cart.deliveryCharge > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Add ₹${(499 - cart.subtotal).toStringAsFixed(0)} more for FREE delivery',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              )),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
