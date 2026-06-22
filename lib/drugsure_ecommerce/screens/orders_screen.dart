// ============================================================
// FILE: screens/orders_screen.dart  (unified – list + tracking)
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_model.dart';

// ─────────────────────────────────────────────────────────────
// ORDER CONFIRMATION SCREEN
// ─────────────────────────────────────────────────────────────
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
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.35), blurRadius: 20, spreadRadius: 4)],
                  ),
                  child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),
              Text('Order Placed! 🎉',
                  style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Your order #${order.id.substring(0, 12)} has been placed\nand is being prepared.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              _infoCard(order),
              const Spacer(),
              _actionButton(
                context: context,
                label: 'Track My Order',
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF1565C0),
                onTap: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
              ),
              const SizedBox(height: 12),
              _actionButton(
                context: context,
                label: 'Continue Shopping',
                icon: Icons.storefront_outlined,
                color: Colors.grey.shade700,
                filled: false,
                onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(Order order) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7FA),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        _infoRow(Icons.confirmation_number_outlined, 'Order ID', order.id.length > 16 ? order.id.substring(0, 16) + '…' : order.id),
        const Divider(height: 20),
        _infoRow(Icons.payment_outlined, 'Payment', '${order.paymentMethod} • ₹${order.total.toStringAsFixed(2)}'),
        const Divider(height: 20),
        _infoRow(Icons.local_shipping_outlined, 'Est. Delivery',
            order.estimatedDelivery != null ? _fmtDate(order.estimatedDelivery!) : '3–5 business days'),
        const Divider(height: 20),
        _infoRow(Icons.location_on_outlined, 'Deliver to',
            '${order.deliveryAddress.city}, ${order.deliveryAddress.state}'),
      ],
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, color: const Color(0xFF1565C0), size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ],
  );

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool filled = true,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 52,
        child: filled
            ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(icon, color: Colors.white, size: 18),
                label: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                onPressed: onTap,
              )
            : OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(icon, color: color, size: 18),
                label: Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                onPressed: onTap,
              ),
      );

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]}, ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────
// ORDERS LIST SCREEN  (real-time Firestore stream)
// ─────────────────────────────────────────────────────────────
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: Text('My Orders',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: uid.isEmpty
          ? _emptyState('Please log in to view your orders.')
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: uid)
                  .orderBy('orderDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _emptyState('Could not load orders.\n${snapshot.error}');
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return _emptyState('No orders yet.\nStart shopping to place your first order!');

                final orders = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;
                  return Order.fromJson(data);
                }).toList();

                return RefreshIndicator(
                  onRefresh: () async {},
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                  ),
                );
              },
            ),
    );
  }

  Widget _emptyState(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 80, color: Color(0xFFBBDEFB)),
          const SizedBox(height: 20),
          Text('No Orders Yet',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text(msg, textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13, height: 1.5)),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// ORDER CARD  (tappable → tracking bottom sheet)
// ─────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return GestureDetector(
      onTap: () => _showTracking(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // ── header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medication_outlined, color: Color(0xFF1565C0), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.id.length > 14 ? order.id.substring(0, 14) : order.id}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          _fmtDate(order.createdAt),
                          style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(order.status.displayName, statusColor),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── items ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record, size: 6, color: Color(0xFF1565C0)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${item.medicineName} × ${item.quantity}',
                              style: GoogleFonts.poppins(fontSize: 12)),
                        ),
                        Text('₹${item.totalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  )),
                  if (order.items.length > 2)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('+${order.items.length - 2} more items',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            // ── footer ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹${order.total.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1565C0))),
                      Text('via ${order.paymentMethod}',
                          style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                  const Spacer(),
                  if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFF1565C0))),
                      ),
                      icon: const Icon(Icons.local_shipping_outlined, size: 15),
                      label: Text('Track', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                      onPressed: () => _showTracking(context),
                    )
                  else
                    _statusChip(order.status == OrderStatus.delivered ? '✓ Delivered' : '✗ Cancelled',
                        order.status == OrderStatus.delivered ? Colors.green : Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────
  Widget _statusChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label,
        style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:          return Colors.blue;
      case OrderStatus.confirmed:       return Colors.indigo;
      case OrderStatus.shipped:         return Colors.orange;
      case OrderStatus.outForDelivery:  return Colors.deepOrange;
      case OrderStatus.delivered:       return Colors.green;
      case OrderStatus.cancelled:       return Colors.red;
      case OrderStatus.pending:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]}, ${d.year}';
  }

  // ── tracking bottom sheet ──────────────────────────────────
  void _showTracking(BuildContext context) {
    final steps = ['Order Placed', 'Confirmed', 'Shipped', 'Out for Delivery', 'Delivered'];
    final currentStep = order.status == OrderStatus.cancelled ? -1 : order.status.stepIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Text('Track Order',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                _statusChip(order.status.displayName, _statusColor(order.status)),
              ],
            ),
            Text('#${order.id.length > 14 ? order.id.substring(0, 14) : order.id}',
                style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 24),

            if (order.status == OrderStatus.cancelled) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200)),
                child: Row(
                  children: [
                    const Icon(Icons.cancel_outlined, color: Colors.red),
                    const SizedBox(width: 12),
                    Text('This order was cancelled.',
                        style: GoogleFonts.poppins(color: Colors.red.shade700)),
                  ],
                ),
              ),
            ] else ...[
              // stepper
              ...List.generate(steps.length, (i) {
                final isDone    = i < currentStep;
                final isCurrent = i == currentStep;
                final isAhead   = i > currentStep;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // dot + line column
                        SizedBox(
                          width: 36,
                          child: Column(
                            children: [
                              Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(
                                  color: isDone || isCurrent
                                      ? const Color(0xFF1565C0)
                                      : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isDone ? Icons.check_rounded : Icons.circle,
                                  size: isDone ? 16 : 10,
                                  color: isDone || isCurrent ? Colors.white : Colors.grey[400],
                                ),
                              ),
                              if (i < steps.length - 1)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: isDone ? const Color(0xFF1565C0) : Colors.grey[200],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                steps[i],
                                style: GoogleFonts.poppins(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                  color: isAhead ? Colors.grey[400] : Colors.black87,
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Current',
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            if (order.estimatedDelivery != null && order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.event_available_outlined, color: Colors.green, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Estimated delivery: ${_fmtDate(order.estimatedDelivery!)}',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
