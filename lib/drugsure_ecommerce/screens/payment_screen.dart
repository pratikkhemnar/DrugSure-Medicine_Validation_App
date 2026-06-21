// ============================================================
// FILE: screens/payment_screen.dart
// ============================================================
//
// RAZORPAY INTEGRATION:
// 1. Add to pubspec.yaml: razorpay_flutter: ^1.3.7
// 2. Get your API keys from https://dashboard.razorpay.com
// 3. Replace 'YOUR_RAZORPAY_KEY' with your actual key
// 4. For production: Use backend to create Razorpay orders
//    POST https://api.razorpay.com/v1/orders
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart' hide CartItem;
import '../services/medicine_service.dart';
import 'orders_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Address selectedAddress;
  final String paymentMethod;

  const PaymentScreen({
    super.key,
    required this.selectedAddress,
    required this.paymentMethod,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final OrderService _orderService = OrderService();
  bool _isProcessing = false;

  // ---- RAZORPAY SETUP ---- (uncomment when package added)
  late Razorpay _razorpay;
  static const String _razorpayKey = 'rzp_test_SsQj3mK7wbAwSF';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _createOrder(paymentId: response.paymentId ?? '');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  void _openRazorpay(double amount) {
    var options = {
      'key': _razorpayKey,
      'amount': (amount * 100).toInt(), // Razorpay amount in paise
      'name': 'DrugSure',
      'description': 'Medicine Order',
      'prefill': {
        'contact': widget.selectedAddress.phone,
        'email': 'user@example.com', // TODO: Get from auth provider
      },
      'theme': {'color': '#1565C0'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay error: $e');
    }

    // TEMPORARY: Simulate payment success for testing
    _createOrder(paymentId: 'pay_demo_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> _createOrder({String paymentId = ''}) async {
    final cart = context.read<CartProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to place an order.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isProcessing = true);

    try {
      final order = await _orderService.placeOrder(
        userId: currentUser.uid,
        cartItems: cart.items.map((ci) => CartItem(
          medicine: ci.medicine,
          quantity: ci.quantity,
        )).toList(),
        deliveryAddress: widget.selectedAddress,
        paymentMethod: widget.paymentMethod,
        paymentId: paymentId,
        subtotal: cart.subtotal,
        discount: 0.0,
        deliveryCharge: cart.deliveryCharge,
        total: cart.total,
      );

      cart.clearCart();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => OrderConfirmationScreen(order: order)),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Delivery address card
            _buildInfoCard(
              icon: Icons.location_on,
              title: 'Delivering to',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.selectedAddress.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.selectedAddress.displayAddress,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  Text(widget.selectedAddress.phone,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment method card
            _buildInfoCard(
              icon: Icons.payment,
              title: 'Payment Method',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPaymentIcon(widget.paymentMethod),
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(widget.paymentMethod,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bill summary
            _buildInfoCard(
              icon: Icons.receipt,
              title: 'Bill Details',
              child: Column(
                children: [
                  ...cart.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text('${item.medicine.name} x${item.quantity}',
                            style: const TextStyle(fontSize: 13))),
                        Text('₹${item.totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  )),
                  const Divider(),
                  _billRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
                  _billRow('Delivery',
                      cart.deliveryCharge == 0 ? 'FREE' : '₹${cart.deliveryCharge.toStringAsFixed(2)}',
                      green: cart.deliveryCharge == 0),
                  _billRow('Total Savings', '-₹${cart.totalSavings.toStringAsFixed(2)}', green: true),
                  const Divider(),
                  _billRow('Total Payable', '₹${cart.total.toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Security badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '100% Secure Payment. Your payment information is encrypted.',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isProcessing ? null : () {
                if (widget.paymentMethod == 'COD') {
                  _createOrder();
                } else {
                  _openRazorpay(cart.total);
                }
              },
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text('Processing...', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    )
                  : Text(
                      widget.paymentMethod == 'COD'
                          ? 'Place Order (COD)'
                          : 'Pay ₹${cart.total.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1565C0), size: 18),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12,
                  fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool bold = false, bool green = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value, style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: green ? Colors.green : bold ? const Color(0xFF1565C0) : null,
          )),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'UPI': return Icons.account_balance_wallet_outlined;
      case 'Card': return Icons.credit_card;
      case 'NetBanking': return Icons.account_balance;
      case 'COD': return Icons.money;
      default: return Icons.payment;
    }
  }
}
