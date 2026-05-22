// ============================================================
// FILE: screens/order_confirmation_screen.dart
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/medicine_service.dart';
import 'orders_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Success animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 100, height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF43A047), shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Order Placed!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Your order #${order.id} has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Order info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.confirmation_number, 'Order ID', order.id),
                    const Divider(height: 20),
                    _infoRow(Icons.payment, 'Payment',
                        '${order.paymentMethod} • ₹${order.total.toStringAsFixed(2)}'),
                    const Divider(height: 20),
                    _infoRow(Icons.local_shipping, 'Estimated Delivery',
                        order.estimatedDelivery != null
                            ? _formatDate(order.estimatedDelivery!)
                            : '3-5 business days'),
                    const Divider(height: 20),
                    _infoRow(Icons.location_on, 'Deliver to',
                        order.deliveryAddress.city + ', ' + order.deliveryAddress.state),
                  ],
                ),
              ),
              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
                  child: const Text('Track My Order',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1565C0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Continue Shopping',
                      style: TextStyle(color: Color(0xFF1565C0),
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1565C0), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

// ============================================================
// FILE: screens/orders_screen.dart
// ============================================================

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;

  // TODO: Replace with auth userId
  final String _userId = FirebaseAuth.instance.currentUser?.uid ??'';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _orderService.getUserOrders(_userId);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('My Orders',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (_, i) => _buildOrderCard(_orders[i]),
                  ),
                ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.id,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(_formatDate(order.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.status.displayName,
                      style: TextStyle(color: statusColor, fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: order.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medication, size: 22, color: Color(0xFF1565C0)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('${item.medicineName} x${item.quantity}',
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Text('₹${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )).toList(),
            ),
          ),

          if (order.items.length > 2)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Text('+${order.items.length - 2} more items',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ),

          const Divider(height: 1),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total: ₹${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0))),
                    Text('via ${order.paymentMethod}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                if (order.status != OrderStatus.delivered &&
                    order.status != OrderStatus.cancelled)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1565C0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showTrackingBottomSheet(order),
                    child: const Text('Track',
                        style: TextStyle(color: Color(0xFF1565C0))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTrackingBottomSheet(Order order) {
    final steps = ['Order Placed', 'Confirmed', 'Shipped', 'Out for Delivery', 'Delivered'];
    final currentStep = order.status.stepIndex;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            ...List.generate(steps.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: i <= currentStep ? const Color(0xFF1565C0) : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      i < currentStep ? Icons.check : Icons.circle,
                      size: 14,
                      color: i <= currentStep ? Colors.white : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(steps[i],
                      style: TextStyle(
                        fontWeight: i == currentStep ? FontWeight.bold : FontWeight.normal,
                        color: i <= currentStep ? Colors.black : Colors.grey[400],
                      )),
                  if (i == currentStep) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Current',
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Your orders will appear here', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed: return Colors.blue;
      case OrderStatus.confirmed: return Colors.indigo;
      case OrderStatus.shipped: return Colors.orange;
      case OrderStatus.outForDelivery: return Colors.deepOrange;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
