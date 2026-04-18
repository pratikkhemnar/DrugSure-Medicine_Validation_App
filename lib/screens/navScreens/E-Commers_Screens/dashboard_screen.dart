import 'dart:async';
import 'package:drugsuremva/screens/navScreens/E-Commers_Screens/product_navigation_screen.dart';
import 'package:flutter/material.dart';

import 'account_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _cartItems = [];
  double _cartTotal = 0.0;

  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Paracetamol 500mg',
      'price': 320,
      'image': 'assets/Cosmetics_images/img_6.png',
      'category': 'Pain Relief',
      'description': 'Effective for headaches, fever, and mild pain.',
      'inStock': true,
    },
    {
      'id': 2,
      'name': 'Ibuprofen 200mg',
      'price': 84,
      'image': 'assets/Cosmetics_images/Ibuprofen.png',
      'category': 'Pain Relief',
      'description': 'Anti-inflammatory for pain and fever reduction.',
      'inStock': true,
    },
    {
      'id': 3,
      'name': 'Cetirizine 10mg',
      'price': 149,
      'image': 'assets/Cosmetics_images/img_1.png',
      'category': 'Allergy',
      'description': 'Relieves allergy symptoms like sneezing and itching.',
      'inStock': true,
    },
    {
      'id': 4,
      'name': 'Omeprazole 20mg',
      'price': 120,
      'image': 'assets/Cosmetics_images/img_2.png',
      'category': 'Acid Reducer',
      'description': 'Treats heartburn and acid reflux.',
      'inStock': true,
    },
    {
      'id': 5,
      'name': 'Vitamin C 1000mg',
      'price': 199,
      'image': 'assets/Cosmetics_images/img_3.png',
      'category': 'Vitamins',
      'description': 'Boosts immune system and overall health.',
      'inStock': true,
    },
    {
      'id': 6,
      'name': 'Multivitamin Complex',
      'price': 195,
      'image': 'assets/Cosmetics_images/img_4.png',
      'category': 'Vitamins',
      'description': 'Complete daily vitamin supplement.',
      'inStock': false,
    },
  ];
  final List<Map<String, dynamic>> _sponsors = [
    {'name': 'Skinovate Cosmetics', 'logo': 'assets/Cosmetics_images/img_12.png'},
    {'name': 'MyUpchar', 'logo': 'assets/Cosmetics_images/img_14.png'},
    {'name': 'PharmEasy', 'logo': 'assets/Cosmetics_images/img_15.png'},
    {'name': 'Tata 1MG', 'logo': 'assets/Cosmetics_images/img_16.png'},
    {'name': 'Cipla', 'logo': 'assets/Cosmetics_images/img_13.png'},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Pain Relief', 'icon': Icons.local_hospital},
    {'name': 'Allergy', 'icon': Icons.air},
    {'name': 'Vitamins', 'icon': Icons.spa},
    {'name': 'Digestive', 'icon': Icons.restaurant},
    {'name': 'First Aid', 'icon': Icons.medical_services},
  ];


  late PageController _pageController;
  int _currentDealPage = 1; // real pages start from index 1
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentDealPage,
      viewportFraction: 0.9,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      _currentDealPage++;
      _pageController.animateToPage(
        _currentDealPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

// Actual deals
  List<Map<String, String>> _realDeals = [
    {
      'title': '',
      'subtitle': '',
      'image': 'assets/images/deal 1.jpg'
    },
    {
      'title': '',
      'subtitle': '',
      'image': 'assets/images/deal3.jpg'
    },
    {
      'title': '',
      'subtitle': '',
      'image': 'assets/images/deal_2.png'
    },
  ];

// Cloned: [last] + [real] + [first]
  List<Map<String, String>> get _deals {
    return [
      _realDeals.last,
      ..._realDeals,
      _realDeals.first,
    ];
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      bool found = false;
      for (var item in _cartItems) {
        if (item['id'] == product['id']) {
          item['quantity'] += 1;
          found = true;
          break;
        }
      }
      if (!found) {
        _cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'image': product['image'],
          'quantity': 1,
        });
      }
      _calculateTotal();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(int productId) {
    setState(() {
      _cartItems.removeWhere((item) => item['id'] == productId);
      _calculateTotal();
    });
  }

  void _updateQuantity(int productId, int newQuantity) {
    setState(() {
      for (var item in _cartItems) {
        if (item['id'] == productId) {
          item['quantity'] = newQuantity;
          break;
        }
      }
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _cartTotal = 0.0;
    for (var item in _cartItems) {
      _cartTotal += item['price'] * item['quantity'];
    }
  }

  void _checkout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: _cartItems,
          cartTotal: _cartTotal,
          onCheckoutComplete: () {
            setState(() {
              _cartItems.clear();
              _cartTotal = 0.0;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('DrugSure', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {},
                    ),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Deals Carousel
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _deals.length,
                  onPageChanged: (index) {
                    _currentDealPage = index;

                    // Loop logic
                    if (index == _deals.length - 1) {
                      // Jump from fake last to real first
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _pageController.jumpToPage(1);
                        _currentDealPage = 1;
                      });
                    } else if (index == 0) {
                      // Jump from fake first to real last
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _pageController.jumpToPage(_deals.length - 2);
                        _currentDealPage = _deals.length - 2;
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    final deal = _deals[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage(deal['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                deal['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                deal['subtitle']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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


              const SizedBox(height: 20),

              // Categories
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RelatedProductsScreen(
                              categoryName: _categories[index]['name'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _categories[index]['icon'],
                              size: 30,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _categories[index]['name'],
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Popular Products
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: _products[index],
                    onAddToCart: _addToCart,
                  );
                },
              ),


        // Add this after all other widgets in your DashboardScreen's Column
        const SizedBox(height: 30),
        const Text(
          'Our Trusted Partners',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _sponsors.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        separatorBuilder: (context, index) => const SizedBox(width: 20),
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              _sponsors[index]['logo'],
                              width: 100,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(
                      height: 1,
                      color: Color(0xFFE0E0E0),
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Trusted by leading pharmaceutical companies',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if(_currentIndex==1){
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(
                cartItems: _cartItems,
                cartTotal: _cartTotal,
                removeFromCart: _removeFromCart,
                updateQuantity: _updateQuantity,
                checkout: _checkout,
              ),));
            } else if(_currentIndex==2){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen()));
            };
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
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


// Cart Screen
class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double cartTotal;
  final Function(int) removeFromCart;
  final Function(int, int) updateQuantity;
  final Function checkout;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.cartTotal,
    required this.removeFromCart,
    required this.updateQuantity,
    required this.checkout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(item['image']),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    title: Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '₹${item['price'].toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green),
                    ),
                    trailing: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.deepPurple),
                              onPressed: () {
                                if (item['quantity'] > 1) {
                                  updateQuantity(item['id'], item['quantity'] - 1);
                                }
                              },
                            ),
                            Text(item['quantity'].toString()),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurple),
                              onPressed: () {
                                updateQuantity(item['id'], item['quantity'] + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹${cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        checkout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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


// CheckOut Screen

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double cartTotal;
  final Function onCheckoutComplete;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.cartTotal,
    required this.onCheckoutComplete,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'card';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with some default values (can be empty)
    _nameController.text = 'John Dia';
    _addressController.text = '123 Main Street';
    _cityController.text = 'Pune';
    _zipController.text = '411048';
    _countryController.text = 'India';
    _phoneController.text = '+91 8877887794';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showAddressForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const Text(
                      'Edit Delivery Address',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Street Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.home),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // City Field
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.location_city),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // ZIP and Country Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _zipController,
                            decoration: InputDecoration(
                              labelText: 'PIN Code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.markunread_mailbox),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter PIN code';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _countryController,
                            decoration: InputDecoration(
                              labelText: 'Country',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.flag),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your country';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {}); // Save the data to state
                            Navigator.pop(context); // Close the bottom sheet
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Save Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple
        ),
      ),
    );
  }

  Widget _buildInfoCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Delivery Address'),
              _buildInfoCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _nameController.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _phoneController.text,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.home, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _addressController.text,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '${_cityController.text}, ${_zipController.text}, ${_countryController.text}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _showAddressForm,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSectionHeader('Payment Method'),
              _buildInfoCard(
                Column(
                  children: [
                    _buildPaymentOption(
                      icon: Icons.credit_card,
                      title: 'Credit/Debit Card',
                      value: 'card',
                    ),
                    if (_selectedPaymentMethod == 'card') _buildCardDetails(),
                    const Divider(height: 20, thickness: 0.5),
                    _buildPaymentOption(
                      icon: Icons.paypal,
                      title: 'UPI',
                      value: 'UPI',
                    ),
                    if (_selectedPaymentMethod == 'UPI') _buildUPIMethods(),
                    const Divider(height: 20, thickness: 0.5),
                    _buildPaymentOption(
                      icon: Icons.money,
                      title: 'Cash on Delivery',
                      value: 'cash',
                    ),
                  ],
                ),
              ),
              _buildSectionHeader('Order Summary'),
              _buildInfoCard(
                Column(
                  children: [
                    ...widget.cartItems.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['name']} x${item['quantity']}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            '\Rs ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(height: 20, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\Rs ${widget.cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    _showConfirmationDialog(context);
                  },
                  child: const Text(
                    'PLACE ORDER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _selectedUPIMethod = 'Google Pay';
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _upiIdController = TextEditingController();

  Widget _buildCardDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryDateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Expiry (MM/YY)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUPIMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedUPIMethod,
          items: ['Google Pay', 'PhonePe', 'Paytm'].map((String method) {
            return DropdownMenuItem<String>(
              value: method,
              child: Text(method),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedUPIMethod = value!;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Select UPI App',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _upiIdController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Enter UPI ID',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }


  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        activeColor: Colors.deepPurple,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value!;
          });
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Order',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Please review your order details:',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Payment Method', _selectedPaymentMethod.toUpperCase()),
              const SizedBox(height: 10),
              _buildDetailRow('Total Amount', '\Rs ${widget.cartTotal.toStringAsFixed(2)}'),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Colors.deepPurple),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onCheckoutComplete();
                        Navigator.pop(context);
                        _showSuccessDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continue to Shopping',
                    style: TextStyle(fontWeight: FontWeight.bold ,color:Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

