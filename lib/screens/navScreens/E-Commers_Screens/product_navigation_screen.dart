import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Adjust path based on your folder structure

class RelatedProductsScreen extends StatelessWidget {
  final String categoryName;

  const RelatedProductsScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> allProducts = [
      {
        'name': 'Paracetamol',
        'description': 'Pain reliever and fever reducer',
        'image': 'assets/Cosmetics_images/img_6.png',
        'category': 'Pain Relief',
        'price': 320,
        'inStock': true,
      },
      {
        'name': 'Ibuprofen 200mg',
        'price': 84,
        'image': 'assets/Cosmetics_images/Ibuprofen.png',
        'category': 'Pain Relief',
        'description': 'Anti-inflammatory for pain and fever reduction.',
        'inStock': true,
      },
      {
        'name': 'Cetirizine',
        'description': 'Allergy relief',
        'image': 'assets/Cosmetics_images/img_1.png',
        'category': 'Allergy',
        'price': 3.20,
        'inStock': true,
      },
      {
        'name': 'Loratadine',
        'description': 'Non-drowsy allergy medicine',
        'image': 'assets/Cosmetics_images/img_7.png',
        'category': 'Allergy',
        'price': 150,
        'inStock': true,
      },
      {
        'name': 'Vitamin C 1000mg',
        'price': 199,
        'image': 'assets/Cosmetics_images/img_3.png',
        'category': 'Vitamins',
        'description': 'Boosts immune system and overall health.',
        'inStock': true,
      },
      {
        'name': 'Vitamin D',
        'description': 'Supports bone health',
        'image': 'assets/Cosmetics_images/img_7.png',
        'category': 'Vitamins',
        'price': 99,
        'inStock': false,
      },
      {
        'name': 'Digene Antacid Tablets',
        'description': 'Relieves acidity, heartburn, and indigestion',
        'image': 'assets/Cosmetics_images/img_8.png',
        'category': 'Digestive',
        'price': 280,
        'inStock': true,
      },
      {
        'name': 'Pudin Hara',
        'description': 'Herbal remedy for gas, indigestion, and stomach pain',
        'image': 'assets/Cosmetics_images/img_9.png',
        'category': 'Digestive',
        'price': 49,
        'inStock': true,
      },
      {
        'name': 'Dettol Antiseptic Liquid',
        'description': 'Disinfectant for cuts, wounds, and first aid',
        'image': 'assets/Cosmetics_images/img_10.png',
        'category': 'First Aid',
        'price': 75,
        'inStock': true,
      },
      {
        'name': 'Savlon Antiseptic Cream',
        'description': 'Heals minor cuts, burns, and skin infections',
        'image': 'assets/Cosmetics_images/img_11.png',
        'category': 'First Aid',
        'price': 35,
        'inStock': true,
      },
    ];

    List<Map<String, dynamic>> relatedProducts = allProducts
        .where((product) => product['category'] == categoryName)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('$categoryName Products')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: relatedProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            var product = relatedProducts[index];
            return ProductCard(
              product: product,
              onAddToCart: (product) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product['name']} added to cart!')),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                image: DecorationImage(
                  image: AssetImage(product['image']),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  product['category'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\Rs ${product['price'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    product['inStock']
                        ? const Text(
                      'In Stock',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    )
                        : const Text(
                      'Out of Stock',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: product['inStock']
                        ? () {
                      onAddToCart(product);
                    }
                        : null,
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
