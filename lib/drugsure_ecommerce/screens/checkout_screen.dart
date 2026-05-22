// ============================================================
// FILE: screens/checkout_screen.dart
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../services/medicine_service.dart';
import 'payment_screen.dart';
import 'add_address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AddressService _addressService = AddressService();
  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoading = true;
  String _paymentMethod = 'UPI';

  // TODO: Replace with actual userId from your auth provider
  // Example with Firebase: FirebaseAuth.instance.currentUser?.uid ?? ''
  final String _userId = FirebaseAuth.instance.currentUser?.uid ??'';

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'UPI', 'icon': Icons.account_balance_wallet_outlined, 'label': 'UPI', 'sub': 'GPay, PhonePe, Paytm'},
    {'id': 'Card', 'icon': Icons.credit_card, 'label': 'Credit/Debit Card', 'sub': 'Visa, Mastercard, Rupay'},
    {'id': 'NetBanking', 'icon': Icons.account_balance, 'label': 'Net Banking', 'sub': 'All major banks'},
    {'id': 'COD', 'icon': Icons.money, 'label': 'Cash on Delivery', 'sub': 'Pay when delivered'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final addresses = await _addressService.getUserAddresses(_userId);
    setState(() {
      _addresses = addresses;
      _selectedAddress = addresses.isNotEmpty
          ? addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first)
          : null;
      _isLoading = false;
    });
  }

  Future<void> _addAddress() async {
    final result = await Navigator.push<Address>(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    if (result != null) {
      setState(() {
        _addresses.add(result);
        _selectedAddress ??= result;
      });
      // TODO: Save to backend
      await _addressService.saveAddress(_userId, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Delivery Address', Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  _buildAddressSection(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Payment Method', Icons.payment),
                  const SizedBox(height: 12),
                  _buildPaymentSection(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Order Summary', Icons.receipt_long_outlined),
                  const SizedBox(height: 12),
                  _buildOrderSummaryCard(cart),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Payable',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('₹${cart.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 18, color: Color(0xFF1565C0))),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAddress == null
                        ? Colors.grey
                        : const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _selectedAddress == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                selectedAddress: _selectedAddress!,
                                paymentMethod: _paymentMethod,
                              ),
                            ),
                          ),
                  child: Text(
                    _selectedAddress == null
                        ? 'Add Address to Continue'
                        : 'Place Order • ₹${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1565C0), size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: [
        ..._addresses.map((addr) => GestureDetector(
              onTap: () => setState(() => _selectedAddress = addr),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedAddress?.id == addr.id
                        ? const Color(0xFF1565C0)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                      blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: addr.id,
                      groupValue: _selectedAddress?.id,
                      activeColor: const Color(0xFF1565C0),
                      onChanged: (v) => setState(() => _selectedAddress = addr),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(addr.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(addr.addressType,
                                    style: const TextStyle(fontSize: 10,
                                        color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
                              ),
                              if (addr.isDefault) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(addr.displayAddress,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(addr.phone,
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        TextButton.icon(
          onPressed: _addAddress,
          icon: const Icon(Icons.add_location_alt, color: Color(0xFF1565C0)),
          label: const Text('Add New Address',
              style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      children: _paymentMethods.map((pm) => GestureDetector(
            onTap: () => setState(() => _paymentMethod = pm['id']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _paymentMethod == pm['id']
                      ? const Color(0xFF1565C0)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: pm['id']!,
                    groupValue: _paymentMethod,
                    activeColor: const Color(0xFF1565C0),
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(pm['icon'] as IconData, color: const Color(0xFF1565C0), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pm['label']!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(pm['sub']!,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          )).toList(),
    );
  }

  Widget _buildOrderSummaryCard(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.medicine.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Qty: ${item.quantity}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('₹${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Subtotal'), Text('₹${cart.subtotal.toStringAsFixed(2)}')]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery'),
                Text(cart.deliveryCharge == 0 ? 'FREE' : '₹${cart.deliveryCharge.toStringAsFixed(2)}',
                    style: cart.deliveryCharge == 0
                        ? const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                        : null),
              ]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Savings', style: TextStyle(color: Colors.green)),
                Text('-₹${cart.totalSavings.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ]),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('₹${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 16, color: Color(0xFF1565C0))),
              ]),
        ],
      ),
    );
  }
}
