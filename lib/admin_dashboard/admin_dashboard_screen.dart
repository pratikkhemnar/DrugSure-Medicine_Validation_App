import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Admin/screens/add_medicine_data.dart';
import 'screens/admin_blockchain_screen.dart';
import 'dash_theme.dart';
import 'dashboard_repository.dart';
import 'widgets/dash_widgets.dart';
import 'tabs/overview_tab.dart';
import 'tabs/alerts_tab.dart';
import 'tabs/tips_tab.dart';
import 'tabs/products_tab.dart';
import 'tabs/orders_tab.dart';

/// Root shell for the admin dashboard.
///
/// This file only handles navigation chrome (AppBar, TabBar, Drawer) and
/// hands off all real work to per-tab widgets in `tabs/`. Each tab owns
/// its own state and talks to Firestore through [DashboardRepository] —
/// nothing here touches FirebaseFirestore directly anymore.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = DashboardRepository();
  final _overviewKey = GlobalKey<OverviewTabState>();

  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    final name = await _repo.fetchAdminName();
    if (mounted) {
      setState(() => _adminName = name);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log out?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('You will need to sign in again to access the dashboard.', style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DashTheme.danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashTheme.bgLight,
      appBar: AppBar(
        title: Text('Admin Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: DashTheme.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh overview',
            onPressed: () => _overviewKey.currentState?.refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 48),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_rounded, size: 20), text: 'Overview'),
                Tab(icon: Icon(Icons.campaign_rounded, size: 20), text: 'Alerts'),
                Tab(icon: Icon(Icons.lightbulb_rounded, size: 20), text: 'Tips'),
                Tab(icon: Icon(Icons.inventory_2_rounded, size: 20), text: 'Products'),
                Tab(icon: Icon(Icons.shopping_cart_rounded, size: 20), text: 'Orders'),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(
            key: _overviewKey,
            adminName: _adminName,
            repo: _repo,
            onGoToAlerts: () => _tabController.animateTo(1),
            onGoToTips: () => _tabController.animateTo(2),
            onGoToProducts: () => _tabController.animateTo(3),
            onGoToOrders: () => _tabController.animateTo(4),
          ),
          AlertsTab(repo: _repo),
          TipsTab(repo: _repo),
          ProductsTab(repo: _repo),
          OrdersTab(repo: _repo),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: DashTheme.headerGradient,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings_rounded, size: 42, color: DashTheme.primary),
                ),
                const SizedBox(height: 12),
                Text(_adminName, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Administrator', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem(Icons.dashboard_rounded, 'Dashboard', 0),
                _drawerItem(
                  Icons.add_circle_outline_rounded,
                  'Add Medicine',
                  -1,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddMedicineScreen()));
                  },
                ),
                _drawerItem(Icons.campaign_rounded, 'Alerts', 1),
                _drawerItem(Icons.lightbulb_rounded, 'Tips', 2),
                _drawerItem(Icons.inventory_2_rounded, 'Products', 3),
                _drawerItem(Icons.shopping_cart_rounded, 'Orders', 4),
                const Divider(),
                _drawerItem(Icons.people_alt_rounded, 'All Users', -1, onTap: _showAllUsers),
                _drawerItem(Icons.bar_chart_rounded, 'Analytics', -1, onTap: _showAnalytics),
                const Divider(),
                _drawerItem(
                  Icons.hub_rounded,
                  '🔗 Blockchain Admin',
                  -1,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminBlockchainScreen()),
                    );
                  },
                ),
                const Divider(),
                _drawerItem(Icons.logout_rounded, 'Logout', -1, isDestructive: true, onTap: _logout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int tabIndex, {VoidCallback? onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? DashTheme.danger : DashTheme.primary),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, color: isDestructive ? DashTheme.danger : DashTheme.textPrimary)),
      onTap: onTap ??
              () {
            Navigator.pop(context);
            if (tabIndex >= 0) _tabController.animateTo(tabIndex);
          },
    );
  }

  void _showAllUsers() {
    final searchCtrl = TextEditingController();
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    decoration: const BoxDecoration(
                      color: DashTheme.primary,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('All Users', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: searchCtrl,
                          onChanged: (v) => setSheetState(() => query = v),
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search by name or email...',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _repo.watchUsers(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        var users = snapshot.data!;

                        if (query.isNotEmpty) {
                          users = users.where((u) {
                            final name = (u['name'] ?? '').toString().toLowerCase();
                            final email = (u['email'] ?? '').toString().toLowerCase();
                            return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
                          }).toList();
                        }

                        if (users.isEmpty) {
                          return EmptyState(icon: Icons.person_off_rounded, title: query.isEmpty ? 'No users found' : 'No users match "$query"');
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: users.length,
                          itemBuilder: (context, i) {
                            final data = users[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: DashTheme.primary.withOpacity(0.12),
                                child: Text(
                                  (data['name'] ?? 'U').toString().isNotEmpty ? data['name'].toString()[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: DashTheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(data['name'] ?? 'No Name', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                              subtitle: Text(data['email'] ?? 'No Email', style: GoogleFonts.poppins(fontSize: 12)),
                              trailing: Text(data['phone'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: DashTheme.textSecondary)),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showAnalytics() async {
    final stats = await _repo.fetchStats();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Analytics', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _analyticsRow('Total Users', stats.users, Icons.people_alt_rounded, DashTheme.info),
            const SizedBox(height: 10),
            _analyticsRow('Total Products', stats.products, Icons.inventory_2_rounded, DashTheme.success),
            const SizedBox(height: 10),
            _analyticsRow('Total Orders', stats.orders, Icons.shopping_cart_rounded, DashTheme.purple),
            const SizedBox(height: 10),
            _analyticsRow('Pending Orders', stats.pendingOrders, Icons.pending_actions_rounded, DashTheme.warning),
            const SizedBox(height: 10),
            _analyticsRow('Low Stock Items', stats.lowStockProducts, Icons.production_quantity_limits_rounded, DashTheme.danger),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.payments_rounded, size: 20, color: DashTheme.primary),
                const SizedBox(width: 10),
                Text('Revenue: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                Text('₹${stats.totalRevenue.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: DashTheme.primary)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _analyticsRow(String title, int value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 13.5))),
        Text(value.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}