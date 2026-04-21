import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String adminName = "Admin";
  Map<String, int> stats = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initControllers();
    _fetchData();
  }

  void _initControllers() {
    const keys = ['alertTitle', 'alertMsg', 'alertDate', 'tipTitle', 'tipSubtitle',
      'productName', 'productPrice', 'productDesc', 'productCat', 'productStock'];
    for (var key in keys) {
      _controllers[key] = TextEditingController();
    }
  }

  Future<void> _fetchData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(uid).get();
    if (adminDoc.exists && mounted) {
      setState(() => adminName = adminDoc['name'] ?? 'Admin');
    }
    await _refreshStats();
  }

  Future<void> _refreshStats() async {
    final futures = await Future.wait([
      FirebaseFirestore.instance.collection('users').get(),
      FirebaseFirestore.instance.collection('products').get(),
      FirebaseFirestore.instance.collection('orders').get(),
      FirebaseFirestore.instance.collection('alerts').get(),
    ]);
    if (mounted) {
      setState(() {
        stats = {
          'users': futures[0].docs.length,
          'products': futures[1].docs.length,
          'orders': futures[2].docs.length,
          'alerts': futures[3].docs.length,
        };
      });
    }
  }

  Future<void> _addToCollection(String collection, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection(collection).add(data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added to $collection"), backgroundColor: Colors.green),
      );
      await _refreshStats();
      _clearFormFields(collection);
    }
  }

  void _clearFormFields(String collection) {
    if (collection == 'alerts') {
      _controllers['alertTitle']?.clear();
      _controllers['alertMsg']?.clear();
      _controllers['alertDate']?.clear();
    } else if (collection == 'tips') {
      _controllers['tipTitle']?.clear();
      _controllers['tipSubtitle']?.clear();
    } else if (collection == 'products') {
      _controllers['productName']?.clear();
      _controllers['productPrice']?.clear();
      _controllers['productDesc']?.clear();
      _controllers['productCat']?.clear();
      _controllers['productStock']?.clear();
    }
  }

  Future<void> _deleteFromCollection(String collection, String id) async {
    await FirebaseFirestore.instance.collection(collection).doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Deleted from $collection"), backgroundColor: Colors.green),
      );
      await _refreshStats();
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshStats),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 48),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: "Overview"),
                Tab(icon: Icon(Icons.notifications_active), text: "Alerts"),
                Tab(icon: Icon(Icons.lightbulb), text: "Tips"),
                Tab(icon: Icon(Icons.inventory_2), text: "Products"),
                Tab(icon: Icon(Icons.shopping_cart), text: "Orders"),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildManageTab('alerts', _buildAlertForm(), _buildAlertCard),
          _buildManageTab('tips', _buildTipForm(), _buildTipCard),
          _buildManageTab('products', _buildProductForm(), _buildProductCard),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildDrawer() => Drawer(
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.teal.shade800, Colors.teal.shade600]),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 45, color: Colors.teal),
              ),
              const SizedBox(height: 10),
              Text(adminName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text("Administrator", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _drawerItem(Icons.dashboard, "Dashboard", 0),
              _drawerItem(Icons.notifications_active, "Alerts", 1),
              _drawerItem(Icons.lightbulb, "Tips", 2),
              _drawerItem(Icons.inventory_2, "Products", 3),
              _drawerItem(Icons.shopping_cart, "Orders", 4),
              const Divider(),
              _drawerItem(Icons.people, "All Users", -1, onTap: _showAllUsers),
              _drawerItem(Icons.bar_chart, "Analytics", -1, onTap: _showAnalytics),
              const Divider(),
              _drawerItem(Icons.logout, "Logout", -1, isDestructive: true, onTap: _logout),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _drawerItem(IconData icon, String title, int tabIndex, {VoidCallback? onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.teal),
      title: Text(title, style: GoogleFonts.poppins(color: isDestructive ? Colors.red : null)),
      onTap: onTap ?? (() {
        Navigator.pop(context);
        if (tabIndex >= 0) _tabController.animateTo(tabIndex);
      }),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome back, $adminName!", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Here's what's happening with your store today.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _statCard("Users", stats['users'] ?? 0, Icons.people, Colors.blue),
              _statCard("Products", stats['products'] ?? 0, Icons.inventory, Colors.green),
              _statCard("Orders", stats['orders'] ?? 0, Icons.shopping_cart, Colors.orange),
              _statCard("Alerts", stats['alerts'] ?? 0, Icons.notifications, Colors.red),
            ],
          ),

          const SizedBox(height: 24),
          Text("Recent Orders", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(height: 280, child: _buildRecentOrders()),

          const SizedBox(height: 24),
          Text("Quick Actions", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 24) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: itemWidth, child: _actionCard("Add Product", Icons.add_business, Colors.green, () => _tabController.animateTo(3))),
                  SizedBox(width: itemWidth, child: _actionCard("Post Alert", Icons.warning, Colors.red, () => _tabController.animateTo(1))),
                  SizedBox(width: itemWidth, child: _actionCard("Post Tip", Icons.lightbulb, Colors.orange, () => _tabController.animateTo(2))),
                  SizedBox(width: itemWidth, child: _actionCard("View Orders", Icons.shopping_cart, Colors.purple, () => _tabController.animateTo(4))),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statCard(String title, int value, IconData icon, Color color) => Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _actionCard(String title, IconData icon, Color color, VoidCallback onTap) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildManageTab(String collection, Widget form, Widget Function(Map<String, dynamic>, String) cardBuilder) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: form,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(collection)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text("No items found", style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: docs.length,
                itemBuilder: (context, i) => cardBuilder(docs[i].data() as Map<String, dynamic>, docs[i].id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlertForm() => Form(
    key: GlobalKey<FormState>(),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Post New Alert", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTextField(_controllers['alertTitle']!, "Alert Title"),
        const SizedBox(height: 8),
        _buildTextField(_controllers['alertMsg']!, "Alert Message", maxLines: 2),
        const SizedBox(height: 8),
        _buildTextField(_controllers['alertDate']!, "Date Label", hint: "e.g., Today"),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _addToCollection('alerts', {
            'title': _controllers['alertTitle']!.text.trim(),
            'message': _controllers['alertMsg']!.text.trim(),
            'date': _controllers['alertDate']!.text.trim(),
            'type': 'info',
            'timestamp': FieldValue.serverTimestamp(),
          }),
          icon: const Icon(Icons.send, size: 18),
          label: const Text("POST ALERT"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    ),
  );

  Widget _buildTipForm() => Form(
    key: GlobalKey<FormState>(),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Post Health Tip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTextField(_controllers['tipTitle']!, "Tip Title"),
        const SizedBox(height: 8),
        _buildTextField(_controllers['tipSubtitle']!, "Tip Description"),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _addToCollection('tips', {
            'title': _controllers['tipTitle']!.text.trim(),
            'subtitle': _controllers['tipSubtitle']!.text.trim(),
            'color': 'teal',
            'timestamp': FieldValue.serverTimestamp(),
          }),
          icon: const Icon(Icons.add, size: 18),
          label: const Text("POST TIP"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    ),
  );

  Widget _buildProductForm() => Form(
    key: GlobalKey<FormState>(),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Add Product", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTextField(_controllers['productName']!, "Product Name"),
        const SizedBox(height: 8),
        _buildTextField(_controllers['productPrice']!, "Price", keyboardType: TextInputType.number, prefix: "\$"),
        const SizedBox(height: 8),
        _buildTextField(_controllers['productDesc']!, "Description", maxLines: 2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField(_controllers['productCat']!, "Category")),
            const SizedBox(width: 8),
            Expanded(child: _buildTextField(_controllers['productStock']!, "Stock", keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _addToCollection('products', {
            'name': _controllers['productName']!.text.trim(),
            'price': double.tryParse(_controllers['productPrice']!.text.trim()) ?? 0,
            'description': _controllers['productDesc']!.text.trim(),
            'category': _controllers['productCat']!.text.trim(),
            'stock': int.tryParse(_controllers['productStock']!.text.trim()) ?? 0,
            'status': 'Available',
            'createdAt': FieldValue.serverTimestamp(),
          }),
          icon: const Icon(Icons.add, size: 18),
          label: const Text("ADD PRODUCT"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    ),
  );

  Widget _buildAlertCard(Map<String, dynamic> data, String id) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.notifications, color: Colors.white, size: 20),
      ),
      title: Text(data['title'] ?? '',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(data['date'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
        onPressed: () => _deleteFromCollection('alerts', id),
      ),
    ),
  );

  Widget _buildTipCard(Map<String, dynamic> data, String id) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
      ),
      title: Text(data['title'] ?? '',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(data['subtitle'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
        onPressed: () => _deleteFromCollection('tips', id),
      ),
    ),
  );

  Widget _buildProductCard(Map<String, dynamic> data, String id) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      dense: true,
      leading: CircleAvatar(
        backgroundColor: Colors.teal.shade100,
        radius: 20,
        child: Text(
          data['name'].toString().isNotEmpty ? data['name'].toString()[0].toUpperCase() : 'P',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      title: Text(data['name'] ?? '',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text("\$${data['price']} | Stock: ${data['stock']} | ${data['category']}",
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: data['status'] == 'Available' ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              data['status'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 9),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () => _deleteFromCollection('products', id),
          ),
        ],
      ),
    ),
  );

  Widget _buildOrdersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!.docs;
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text("No orders yet", style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final data = orders[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 20,
                  child: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                ),
                title: Text(
                  "Order #${data['orderId'] ?? orders[i].id.substring(0, 8)}",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text("Total: \$${data['totalAmount']} | Date: ${_formatDate(data['orderDate'])}"),
                trailing: DropdownButton<String>(
                  value: data['status'] ?? 'Pending',
                  items: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                      .toList(),
                  onChanged: (newStatus) async {
                    await FirebaseFirestore.instance.collection('orders').doc(orders[i].id).update({'status': newStatus});
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Order updated"), duration: Duration(seconds: 1)),
                      );
                    }
                  },
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        ...?data['items']?.map<Widget>((item) => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 2),
                          child: Text("• ${item['name']} x${item['quantity']} - \$${item['price']}",
                              style: const TextStyle(fontSize: 12)),
                        )).toList(),
                        const SizedBox(height: 8),
                        const Text("Shipping Address:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(data['shippingAddress']?['address'] ?? 'N/A',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!.docs;
        if (orders.isEmpty) {
          return Center(
            child: Text("No recent orders", style: GoogleFonts.poppins(color: Colors.grey)),
          );
        }
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final data = orders[i].data() as Map<String, dynamic>;
            return ListTile(
              dense: true,
              leading: const Icon(Icons.shopping_cart, size: 20),
              title: Text(
                "Order #${data['orderId'] ?? orders[i].id.substring(0, 8)}",
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Text("\$${data['totalAmount']}", style: const TextStyle(fontSize: 12)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data['status'] ?? 'Pending',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController? c, String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    String? prefix,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  void _showAllUsers() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Text(
                  "All Users (${stats['users'] ?? 0})",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final users = snapshot.data!.docs;
                    if (users.isEmpty) {
                      return const Center(child: Text("No users found"));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: users.length,
                      itemBuilder: (context, i) {
                        final data = users[i].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person, size: 20)),
                          title: Text(data['name'] ?? 'No Name', style: const TextStyle(fontSize: 14)),
                          subtitle: Text(data['email'] ?? 'No Email', style: const TextStyle(fontSize: 12)),
                          trailing: Text(data['phone'] ?? 'No Phone', style: const TextStyle(fontSize: 12)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Analytics"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _analyticsRow("Total Users", stats['users'] ?? 0, Icons.people, Colors.blue),
            const SizedBox(height: 8),
            _analyticsRow("Total Products", stats['products'] ?? 0, Icons.inventory, Colors.green),
            const SizedBox(height: 8),
            _analyticsRow("Total Orders", stats['orders'] ?? 0, Icons.shopping_cart, Colors.orange),
            const SizedBox(height: 8),
            _analyticsRow("Total Alerts", stats['alerts'] ?? 0, Icons.notifications, Colors.red),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _analyticsRow(String title, int value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text("$title:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Text(value.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy').format(timestamp.toDate());
    }
    return 'N/A';
  }
}