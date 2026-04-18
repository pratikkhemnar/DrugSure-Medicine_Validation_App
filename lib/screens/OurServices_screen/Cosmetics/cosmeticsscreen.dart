import 'package:flutter/material.dart';

class CosmeticsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {
      "name": "Skincare",
      "icon": Icons.spa,
      "color": Color(0xFF4CAF50),
      "products": [
        {
          "id": "1",
          "name": "Skinovate Skin brightening Night Cream",
          "description": "Hydroquinone & Tranexamic Acid: Fades dark spots overnight, unveiling a luminous, even tone ✨Retinol & Vitamin C: Boost collagen while you sleep, smoothing wrinkles for youthful firmness1 🌱Hyaluronic Acid & Vitamin E: Deeply hydrates, plumping skin and erasing dryness 💧",
          "price": 450.00,
          "image": "assets/Cosmetics_images/skin1.png",
          "rating": 4.8,
        },
        {
          "id": "2",
          "name": "Skinovate SPF 50 PA++++ Sunscreen",
          "description": "Blue Light Defense: Shields from digital damage, keeping skin healthy indoors and out 💻SPF 50 PA++++: Ultimate defense, shielding skin from harmful UVA/UVB rays 🛡️Non-Comedogenic & Gentle: Protects without clogging pores, perfect for sensitive skin 🌿",
          "price": 640.00,
          "image": "assets/Cosmetics_images/skin2.png",
          "rating": 4.9,
          "size": ["30ml"]
        },
        {
          "id": "3",
          "name": "Cetaphil Gentle Skin Cleanser",
          "description": "Mild, non-irritating formula that soothes skin as it cleans. Ideal for dry to normal skin 🧼",
          "price": 320.00,
          "image": "assets/Cosmetics_images/skin8.png",
          "rating": 4.7,
          "size": ["100ml", "250ml"]
        }
      ]
    },
    {
      "name": "Haircare",
      "icon": Icons.water_drop,
      "color": Color(0xFF2196F3),
      "products": [
        {
          "id": "3",
          "name": "Skinovate Hair Oil | Dermatologically Tested | Promotes Hair Growth",
          "description": "Bhringraj & Amla: Ignites growth, strengthening roots for visibly fuller hair 🌱Black Seed Onion Oil: Stops shedding, boosting thickness and resilience 💪Tea Tree & Neem: Clears scalp, eliminating dandruff for optimal health",
          "price": 568.00,
          "image": "assets/Cosmetics_images/skin3.png",
          "rating": 4.7,
        },
        {
          "id": "4",
          "name": "Skinovate Hair Shampoo",
          "description": "Biotin & Niacinamide: Fortify strands, minimizing thinning for noticeably fuller hair 🌱Caffeine & Beet Root: Invigorate follicles, dramatically reducing hair fall and boosting volume 💪Argan & Coconut: Hydrate intensely, restoring shine & softness to every strand ✨",
          "price": 843.00,
          "image": "assets/Cosmetics_images/skin4.png",
          "rating": 4.6,
        },
        {
          "id": "3",
          "name": "WOW Skin Science Hair Conditioner",
          "description": "Coconut + Avocado Oil Conditioner for silky smooth, nourished hair 🌴🥑",
          "price": 349.00,
          "image": "assets/Cosmetics_images/skin9.png",
          "rating": 4.5,
          "size": ["300ml"]
        }
      ]
    },
    {
      "name": "Makeup",
      "icon": Icons.brush,
      "color": Color(0xFFE91E63),
      "products": [
        {
          "id": "1",
          "name": "Maybelline Fit Me Foundation",
          "description": "Matte + Poreless formula for normal to oily skin. Blends seamlessly and controls shine for a flawless finish 💁‍♀️",
          "price": 299.00,
          "image": "assets/Cosmetics_images/skin5.png",
          "rating": 4.6,
          "size": ["30ml", "50ml"]
        },
        {
          "id": "2",
          "name": "Lakmé 9 to 5 Primer + Matte Lipstick",
          "description": "Long-lasting matte lipstick with built-in primer. Smooth texture and intense color 💄",
          "price": 199.00,
          "image": "assets/Cosmetics_images/skin6.png",
          "rating": 4.7,
          "size": ["3.6g"]
        },
        {
          "id": "3",
          "name": "L’Oréal Voluminous Mascara",
          "description": "Instant volume & length without clumps. Defines lashes for bold, dramatic eyes 👁️",
          "price": 799.00,
          "image": "assets/Cosmetics_images/skin7.png",
          "rating": 4.8,
          "size": ["8ml"]
        }
      ]
    },
    {
      "name": "Fragrance",
      "icon": Icons.local_florist,
      "color": Color(0xFF9C27B0),
      "products": [
        {
          "id": "1",
          "name": "Engage L’amante Eau De Parfum",
          "description": "Luxury French perfume for women with floral and fruity notes. Long-lasting elegance 💐",
          "price": 899.00,
          "image": "assets/Cosmetics_images/sent1.png",
          "rating": 4.9,
          "size": ["75ml"]
        },
        {
          "id": "2",
          "name": "Fogg Xtremo Scent For Men",
          "description": "Bold and masculine fragrance for all-day freshness. Great for daily wear or parties 💪",
          "price": 599.00,
          "image": "assets/Cosmetics_images/sent2.png",
          "rating": 4.7,
          "size": ["100ml"]
        },
        {
          "id": "3",
          "name": "MINISO Dazzle Eau De Toilette",
          "description": "Elegant floral scent with a refreshing touch. Affordable and stylish pick 🌸",
          "price": 360.00,
          "image": "assets/Cosmetics_images/sent3.png",
          "rating": 4.5,
          "size": ["50ml"]
        }
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Medical Cosmetics',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Badge(
              child: Icon(Icons.shopping_cart, size: 24),
              smallSize: 12,
            ),
            onPressed: () {},
            color: Colors.black87,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promo Banner
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              height: 180,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/Cosmetics_images/cosmeticbanner.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Premium Medical Cosmetics',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 2,
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                )
                              ],
                            )),
                        SizedBox(height: 8),
                        Text('20% off on all dermatologist-recommended products',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            )),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color(0xFF6A11CB),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            elevation: 2,
                          ),
                          onPressed: () {},
                          child: Text('Shop Now',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Categories Section
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      )),
                  TextButton(
                    onPressed: () {},
                    child: Text('View All',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Material(
                    borderRadius: BorderRadius.circular(16),
                    color: categories[index]["color"].withOpacity(0.1),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (categories[index]["products"].isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryProductsScreen(category: categories[index]),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: categories[index]["color"].withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                categories[index]["icon"],
                                size: 28,
                                color: categories[index]["color"],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              categories[index]["name"],
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Featured Products Section
            Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Featured Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      )),
                  TextButton(
                    onPressed: () {},
                    child: Text('View All',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
            ),
            Container(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories[0]["products"].length + categories[1]["products"].length,
                itemBuilder: (context, index) {
                  final product = index < categories[0]["products"].length
                      ? categories[0]["products"][index]
                      : categories[1]["products"][index - categories[0]["products"].length];
                  return Container(
                    width: 180,
                    margin: EdgeInsets.only(right: 16),
                    child: ProductCard(product: product),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    product["image"],
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        product["rating"].toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                      Spacer(),
                      if (product["size"] != null)
                        Text(
                          product["size"][0],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '\RS ${product["price"].toString()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
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

class CategoryProductsScreen extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryProductsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category["name"]),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: category["products"].length,
        itemBuilder: (context, index) {
          final product = category["products"][index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            child: ProductCard(product: product),
          );
        },
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: product["id"],
                  child: Image.asset(
                    product["image"],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.black87),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product["name"],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          product["rating"].toString(),
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "(120 reviews)",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'In Stock',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '\RS ${product["price"].toString()}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 24),
                    Divider(height: 1, color: Colors.grey[200]),
                    SizedBox(height: 16),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      product["description"],
                      style: TextStyle(
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 24),
                    if (product["size"] != null && product["size"].length > 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sizes Available",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (product["size"] as List).map((size) =>
                                ChoiceChip(
                                  label: Text(size),
                                  selected: size == product["size"][0],
                                  selectedColor: Colors.blue.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: size == product["size"][0]
                                        ? Colors.blue
                                        : Colors.black87,
                                  ),
                                  onSelected: (selected) {},
                                ),
                            ).toList(),
                          ),
                        ],
                      ),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(Icons.shopping_cart, size: 20),
                            label: Text('Add to Cart',
                                style: TextStyle(fontSize: 16)),
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.blue),
                              ),
                            ),
                            onPressed: () {},
                            child: Icon(Icons.favorite_border, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}