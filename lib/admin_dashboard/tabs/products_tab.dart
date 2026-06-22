import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dash_theme.dart';
import '../dashboard_repository.dart';
import '../model/dashboard_models.dart';
import '../widgets/dash_widgets.dart';

class ProductsTab extends StatefulWidget {
  final DashboardRepository repo;
  const ProductsTab({super.key, required this.repo});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String _query = '';
  String _categoryFilter = 'All';
  bool _submitting = false;
  bool _formExpanded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    _stockCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repo.addProduct(
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        description: _descCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        stock: int.parse(_stockCtrl.text.trim()),
      );
      _nameCtrl.clear();
      _priceCtrl.clear();
      _descCtrl.clear();
      _categoryCtrl.clear();
      _stockCtrl.clear();
      if (mounted) {
        showDashSnackBar(context, 'Product added successfully');
        setState(() => _formExpanded = false);
      }
    } catch (e) {
      if (mounted) showDashSnackBar(context, 'Failed to add product: $e', isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete(ProductItem product) async {
    final confirmed = await confirmDelete(context, '"${product.name}"');
    if (!confirmed) return;
    try {
      await widget.repo.deleteDocument('products', product.id);
      if (mounted) showDashSnackBar(context, 'Product deleted');
    } catch (e) {
      if (mounted) showDashSnackBar(context, 'Failed to delete: $e', isError: true);
    }
  }

  Future<void> _editProduct(ProductItem product) async {
    final nameCtrl = TextEditingController(text: product.name);
    final priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));
    final stockCtrl = TextEditingController(text: product.stock.toString());
    final descCtrl = TextEditingController(text: product.description);
    final editKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Product', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Form(
          key: editKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a valid price' : null,
                ),
                TextFormField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  validator: (v) => int.tryParse(v ?? '') == null ? 'Enter a valid number' : null,
                ),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DashTheme.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (editKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      final newStock = int.parse(stockCtrl.text.trim());
      try {
        await widget.repo.updateProduct(product.id, {
          'name': nameCtrl.text.trim(),
          'price': double.parse(priceCtrl.text.trim()),
          'stock': newStock,
          'description': descCtrl.text.trim(),
          'status': newStock > 0 ? 'Available' : 'Out of Stock',
        });
        if (mounted) showDashSnackBar(context, 'Product updated');
      } catch (e) {
        if (mounted) showDashSnackBar(context, 'Update failed: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<ProductItem>>(
            stream: widget.repo.watchProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const ShimmerList();

              var products = snapshot.data!;

              final categories = <String>{'All', ...products.map((p) => p.category).where((c) => c.isNotEmpty)};

              if (_categoryFilter != 'All') {
                products = products.where((p) => p.category == _categoryFilter).toList();
              }
              if (_query.isNotEmpty) {
                products = products.where((p) => p.name.toLowerCase().contains(_query.toLowerCase())).toList();
              }

              return Column(
                children: [
                  _buildCategoryChips(categories),
                  Expanded(
                    child: products.isEmpty
                        ? EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: _query.isEmpty && _categoryFilter == 'All' ? 'No products yet' : 'No products match your filters',
                      subtitle: _query.isEmpty && _categoryFilter == 'All' ? 'Tap "Add Product" above' : null,
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      itemCount: products.length,
                      itemBuilder: (context, i) => _productCard(products[i]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: DashTheme.bgLight,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DashSearchBar(controller: _searchCtrl, hint: 'Search products...', onChanged: (v) => setState(() => _query = v)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => setState(() => _formExpanded = !_formExpanded),
                icon: Icon(_formExpanded ? Icons.close : Icons.add, size: 18),
                label: Text(_formExpanded ? 'Close' : 'Add Product', style: GoogleFonts.poppins(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _formExpanded ? Colors.grey.shade300 : DashTheme.success,
                  foregroundColor: _formExpanded ? DashTheme.textPrimary : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _formExpanded ? _buildForm() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(Set<String> categories) {
    return Container(
      height: 44,
      color: DashTheme.bgLight,
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: categories.map((cat) {
          final selected = _categoryFilter == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat, style: GoogleFonts.poppins(fontSize: 11.5, color: selected ? Colors.white : DashTheme.textPrimary)),
              selected: selected,
              onSelected: (_) => setState(() => _categoryFilter = cat),
              selectedColor: DashTheme.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: DashTheme.cardBorder)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(_nameCtrl, 'Product Name', validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
            const SizedBox(height: 8),
            _field(
              _priceCtrl,
              'Price',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefix: '₹ ',
              validator: (v) {
                final parsed = double.tryParse(v?.trim() ?? '');
                if (parsed == null) return 'Enter a valid price';
                if (parsed <= 0) return 'Price must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 8),
            _field(_descCtrl, 'Description', maxLines: 2),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _field(_categoryCtrl, 'Category', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
                const SizedBox(width: 8),
                Expanded(
                  child: _field(
                    _stockCtrl,
                    'Stock',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final parsed = int.tryParse(v?.trim() ?? '');
                      if (parsed == null) return 'Enter a valid number';
                      if (parsed < 0) return 'Cannot be negative';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_rounded, size: 18),
                label: Text(_submitting ? 'Adding...' : 'ADD PRODUCT', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashTheme.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: DashTheme.radiusSm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        border: OutlineInputBorder(borderRadius: DashTheme.radiusSm),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _productCard(ProductItem product) {
    final lowStock = product.isLowStock;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DashTheme.radiusMd,
        border: Border.all(color: lowStock ? DashTheme.warning.withOpacity(0.4) : DashTheme.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: DashTheme.primary.withOpacity(0.12),
          radius: 20,
          child: Text(
            product.name.isNotEmpty ? product.name[0].toUpperCase() : 'P',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: DashTheme.primary),
          ),
        ),
        title: Text(product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text('₹${product.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 12, color: DashTheme.textSecondary)),
              const SizedBox(width: 8),
              Text('•', style: GoogleFonts.poppins(color: DashTheme.textSecondary)),
              const SizedBox(width: 8),
              Icon(lowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined, size: 13, color: lowStock ? DashTheme.warning : DashTheme.textSecondary),
              const SizedBox(width: 2),
              Text('${product.stock} left', style: GoogleFonts.poppins(fontSize: 12, color: lowStock ? DashTheme.warning : DashTheme.textSecondary)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: product.status == 'Available' ? DashTheme.success.withOpacity(0.12) : DashTheme.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product.status,
                style: GoogleFonts.poppins(
                  color: product.status == 'Available' ? DashTheme.success : DashTheme.danger,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.edit_outlined, color: DashTheme.info, size: 19), onPressed: () => _editProduct(product)),
            IconButton(icon: const Icon(Icons.delete_outline_rounded, color: DashTheme.danger, size: 19), onPressed: () => _delete(product)),
          ],
        ),
      ),
    );
  }
}