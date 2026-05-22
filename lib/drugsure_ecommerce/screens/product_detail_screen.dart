// ============================================================
// FILE: screens/product_detail_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine_model.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Medicine medicine;
  const ProductDetailScreen({super.key, required this.medicine});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medicine;
    final cart = context.watch<CartProvider>();
    final inCart = cart.isInCart(med.id);
    final qty = cart.getQuantity(med.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            actions: [
              IconButton(
                icon: Icon(_isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: _isWishlisted ? Colors.red : Colors.white),
                onPressed: () => setState(() => _isWishlisted = !_isWishlisted),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Color(0xFFFF5722), shape: BoxShape.circle),
                        child: Text('${cart.itemCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFE3F2FD),
                padding: const EdgeInsets.all(40),
                child: med.imageUrl.startsWith('http')
                    ? Image.network(med.imageUrl, fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.medication,
                            size: 100, color: Color(0xFF1565C0)))
                    : const Icon(Icons.medication, size: 100, color: Color(0xFF1565C0)),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Brand
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('by ${med.brand}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                      ),
                      if (med.requiresPrescription)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFF6F00)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.description, size: 14, color: Color(0xFFFF6F00)),
                              SizedBox(width: 4),
                              Text('Rx Required',
                                  style: TextStyle(color: Color(0xFFFF6F00),
                                      fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('₹${med.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 26,
                                    fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                            Row(
                              children: [
                                Text('MRP ₹${med.mrp.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 13,
                                        decoration: TextDecoration.lineThrough)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF43A047).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('${med.discountPercent}% off',
                                      style: const TextStyle(color: Color(0xFF43A047),
                                          fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Color(0xFFFFA726)),
                                Text(' ${med.rating}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text('${med.reviewCount} reviews',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pack size & availability
                  Row(
                    children: [
                      _infoChip(Icons.inventory_2_outlined, med.packSize),
                      const SizedBox(width: 8),
                      _infoChip(
                        med.inStock ? Icons.check_circle_outline : Icons.cancel_outlined,
                        med.inStock ? 'In Stock' : 'Out of Stock',
                        color: med.inStock ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1565C0),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF1565C0),
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Uses'),
                      Tab(text: 'Side Effects'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Details Tab
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailRow('Composition', med.composition),
                              _detailRow('Manufacturer', med.manufacturer),
                              _detailRow('Dosage', med.dosage),
                              _detailRow('Category', med.category),
                              const SizedBox(height: 8),
                              Text(med.description,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ),
                        // Uses Tab
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: med.uses.map((use) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF43A047)),
                                  const SizedBox(width: 8),
                                  Text(use, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                        // Side Effects Tab
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: med.sideEffects.map((se) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber, size: 16, color: Color(0xFFFF6F00)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(se, style: const TextStyle(fontSize: 14))),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: med.inStock
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: inCart
                    ? Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF1565C0), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Color(0xFF1565C0)),
                                    onPressed: () => context.read<CartProvider>()
                                        .decreaseQuantity(med.id),
                                  ),
                                  Text('$qty',
                                      style: const TextStyle(fontSize: 18,
                                          fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Color(0xFF1565C0)),
                                    onPressed: () => context.read<CartProvider>()
                                        .increaseQuantity(med.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const CartScreen())),
                                child: const Text('Go to Cart',
                                    style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            context.read<CartProvider>().addItem(med);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${med.name} added to cart'),
                                backgroundColor: const Color(0xFF1565C0),
                                behavior: SnackBarBehavior.floating,
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  textColor: Colors.white,
                                  onPressed: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => const CartScreen())),
                                ),
                              ),
                            );
                          },
                          child: const Text('Add to Cart',
                              style: TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _infoChip(IconData icon, String label, {Color color = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
