// ============================================================
// FILE: screens/medicine_store_screen.dart
// ============================================================
// NAVIGATE FROM DASHBOARD:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => const MedicineStoreScreen(),
//   ));
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine_model.dart';
import '../providers/cart_provider.dart';
import '../services/medicine_service.dart';
import '../widgets/medicine_card.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class MedicineStoreScreen extends StatefulWidget {
  const MedicineStoreScreen({super.key});

  @override
  State<MedicineStoreScreen> createState() => _MedicineStoreScreenState();
}

class _MedicineStoreScreenState extends State<MedicineStoreScreen> {
  final MedicineService _service = MedicineService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Medicine> _allMedicines = [];
  List<Medicine> _filteredMedicines = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  bool _isSearching = false;

  final List<String> _categories = [
    'All', 'Pain Relief', 'Antibiotics', 'Allergy',
    'Gastro', 'Vitamins', 'Diabetes',
  ];

  final List<Map<String, dynamic>> _banners = [
    {'title': 'Up to 25% off', 'subtitle': 'On all medicines today!', 'color': const Color(0xFF1565C0)},
    {'title': 'Free Delivery', 'subtitle': 'Orders above ₹499', 'color': const Color(0xFF2E7D32)},
    {'title': 'Prescription Medicines', 'subtitle': 'Upload & get doorstep delivery', 'color': const Color(0xFF6A1B9A)},
  ];

  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final medicines = await _service.getAllMedicines();
      setState(() {
        _allMedicines = medicines;
        _filteredMedicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredMedicines = _allMedicines;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await _service.searchMedicines(query);
    setState(() {
      _filteredMedicines = results;
      _isSearching = false;
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      if (category == 'All') {
        _filteredMedicines = _allMedicines;
      } else {
        _filteredMedicines = _allMedicines.where((m) => m.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: const Text(
          'Medicine Store',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5722),
                      shape: BoxShape.circle,
                    ),
                    child: Text('${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search medicines, brands...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)))
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            })
                        : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMedicines,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildBannerCarousel()),
                  SliverToBoxAdapter(child: _buildCategorySection()),
                  SliverToBoxAdapter(child: _buildSectionHeader('All Medicines', _filteredMedicines.length)),
                  _filteredMedicines.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.68,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return MedicineCard(
                                  medicine: _filteredMedicines[index],
                                  onTap: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) =>
                                          ProductDetailScreen(medicine: _filteredMedicines[index]))),
                                );
                              },
                              childCount: _filteredMedicines.length,
                            ),
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
      floatingActionButton: cart.itemCount > 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1565C0),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text('${cart.itemCount} items • ₹${cart.total.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildBannerCarousel() {
    return Container(
      height: 140,
      margin: const EdgeInsets.all(16),
      child: PageView.builder(
        onPageChanged: (i) => setState(() => _currentBanner = i),
        itemCount: _banners.length,
        itemBuilder: (_, i) {
          final banner = _banners[i];
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [banner['color'] as Color, (banner['color'] as Color).withOpacity(0.7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(banner['title']!,
                    style: const TextStyle(color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(banner['subtitle']!,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Shop Now',
                      style: TextStyle(color: banner['color'] as Color,
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => _filterByCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1565C0) : Colors.grey[300]!,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3),
                            blurRadius: 8, offset: const Offset(0, 2))]
                        : [],
                  ),
                  child: Text(cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: const TextStyle(color: Color(0xFF1565C0), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No medicines found', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
