// ============================================================
// FILE: widgets/medicine_card.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine_model.dart';
import '../providers/cart_provider.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;

  const MedicineCard({super.key, required this.medicine, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final inCart = cart.isInCart(medicine.id);
    final qty = cart.getQuantity(medicine.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    color: const Color(0xFFE3F2FD),
                    child: medicine.imageUrl.startsWith('http')
                        ? Image.network(medicine.imageUrl, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.medication, size: 50, color: Color(0xFF1565C0)))
                        : const Icon(Icons.medication, size: 50, color: Color(0xFF1565C0)),
                  ),
                ),
                if (medicine.discountPercent > 0)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${medicine.discountPercent}% OFF',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (medicine.requiresPrescription)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6F00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Rx',
                          style: TextStyle(color: Colors.white,
                              fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (!medicine.inStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: Colors.red,
                        child: const Text('OUT OF STOCK',
                            style: TextStyle(color: Colors.white, fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicine.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(medicine.packSize,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('₹${medicine.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 15, color: Color(0xFF1565C0))),
                      const SizedBox(width: 6),
                      Text('₹${medicine.mrp.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12,
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFFFFA726)),
                      const SizedBox(width: 2),
                      Text('${medicine.rating}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFFFA726))),
                      Text(' (${medicine.reviewCount})',
                          style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Add to cart
            Padding(
              padding: const EdgeInsets.all(10),
              child: medicine.inStock
                  ? inCart
                      ? Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF1565C0)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.read<CartProvider>()
                                          .decreaseQuantity(medicine.id),
                                      child: const Icon(Icons.remove, size: 16,
                                          color: Color(0xFF1565C0)),
                                    ),
                                    Text('$qty',
                                        style: const TextStyle(fontWeight: FontWeight.bold,
                                            color: Color(0xFF1565C0))),
                                    GestureDetector(
                                      onTap: () => context.read<CartProvider>()
                                          .increaseQuantity(medicine.id),
                                      child: const Icon(Icons.add, size: 16,
                                          color: Color(0xFF1565C0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => context.read<CartProvider>().addItem(medicine),
                            child: const Text('Add', style: TextStyle(fontSize: 13)),
                          ),
                        )
                  : SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: null,
                        child: const Text('Unavailable',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
