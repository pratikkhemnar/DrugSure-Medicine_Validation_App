import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../drugsure_ecommerce/models/order_model.dart';
import '../dash_theme.dart';
import '../dashboard_repository.dart';
import '../model/dashboard_models.dart';
import '../widgets/dash_widgets.dart';

class OverviewTab extends StatefulWidget {
  final String adminName;
  final DashboardRepository repo;
  final VoidCallback onGoToAlerts;
  final VoidCallback onGoToTips;
  final VoidCallback onGoToProducts;
  final VoidCallback onGoToOrders;

  const OverviewTab({
    super.key,
    required this.adminName,
    required this.repo,
    required this.onGoToAlerts,
    required this.onGoToTips,
    required this.onGoToProducts,
    required this.onGoToOrders,
  });

  @override
  State<OverviewTab> createState() => OverviewTabState();
}

class OverviewTabState extends State<OverviewTab> {
  DashboardStats _stats = const DashboardStats();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  /// Public so the parent shell's refresh button can trigger this
  /// via a GlobalKey, without re-fetching unrelated tabs.
  Future<void> refresh() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final stats = await widget.repo.fetchStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Defined here, needs to be passed down to helper methods that use it
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: refresh,
      color: DashTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${widget.adminName}!',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: DashTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              "Here's what's happening with DrugSure today.",
              style: GoogleFonts.poppins(
                  fontSize: 13, color: DashTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // Revenue hero card
            _buildRevenueCard(currency),
            const SizedBox(height: 16),

            if (_loading)
              const ShimmerList(itemCount: 2)
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DashTheme.danger.withOpacity(0.07),
                  borderRadius: DashTheme.radiusSm,
                  border: Border.all(color: DashTheme.danger.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: DashTheme.danger, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Could not load stats. Tap refresh to retry.',
                        style: GoogleFonts.poppins(fontSize: 12.5, color: DashTheme.danger),
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    title: 'Total Users',
                    value: _stats.users,
                    icon: Icons.people_alt_rounded,
                    color: DashTheme.info,
                  ),
                  StatCard(
                    title: 'Products',
                    value: _stats.products,
                    icon: Icons.inventory_2_rounded,
                    color: DashTheme.success,
                    onTap: widget.onGoToProducts,
                  ),
                  StatCard(
                    title: 'Total Orders',
                    value: _stats.orders,
                    icon: Icons.shopping_cart_rounded,
                    color: DashTheme.purple,
                    onTap: widget.onGoToOrders,
                  ),
                  StatCard(
                    title: 'Active Alerts',
                    value: _stats.alerts,
                    icon: Icons.notifications_active_rounded,
                    color: DashTheme.danger,
                    onTap: widget.onGoToAlerts,
                  ),
                ],
              ),

            if (!_loading &&
                (_stats.pendingOrders > 0 || _stats.lowStockProducts > 0)) ...[
              const SizedBox(height: 16),
              _buildWarningBanners(),
            ],

            const SizedBox(height: 24),
            SectionHeader(
              title: 'Recent Orders',
              trailing: TextButton(
                onPressed: widget.onGoToOrders,
                child: Text('View all',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: DashTheme.primary)),
              ),
            ),
            const SizedBox(height: 8),
            // Pass the currency formatter here!
            SizedBox(height: 280, child: _buildRecentOrders(currency)),

            const SizedBox(height: 24),
            SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                        width: itemWidth,
                        child: _actionCard(
                            'Add Product',
                            Icons.add_business_rounded,
                            DashTheme.success,
                            widget.onGoToProducts)),
                    SizedBox(
                        width: itemWidth,
                        child: _actionCard(
                            'Post Alert',
                            Icons.campaign_rounded,
                            DashTheme.danger,
                            widget.onGoToAlerts)),
                    SizedBox(
                        width: itemWidth,
                        child: _actionCard(
                            'Post Tip',
                            Icons.lightbulb_rounded,
                            DashTheme.warning,
                            widget.onGoToTips)),
                    SizedBox(
                        width: itemWidth,
                        child: _actionCard(
                            'View Orders',
                            Icons.receipt_long_rounded,
                            DashTheme.purple,
                            widget.onGoToOrders)),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(NumberFormat currency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: DashTheme.radiusMd,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DashTheme.primaryDark, DashTheme.primary],
        ),
        boxShadow: [
          BoxShadow(
              color: DashTheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Revenue',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 6),
                _loading
                    ? const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Text(
                  currency.format(_stats.totalRevenue),
                  style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Across ${_stats.orders} orders',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.trending_up_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanners() {
    return Column(
      children: [
        if (_stats.pendingOrders > 0)
          _warningBanner(
            icon: Icons.pending_actions_rounded,
            text: '${_stats.pendingOrders} order(s) awaiting action',
            color: DashTheme.warning,
            onTap: widget.onGoToOrders,
          ),
        if (_stats.lowStockProducts > 0) ...[
          const SizedBox(height: 8),
          _warningBanner(
            icon: Icons.production_quantity_limits_rounded,
            text: '${_stats.lowStockProducts} product(s) running low on stock',
            color: DashTheme.danger,
            onTap: widget.onGoToProducts,
          ),
        ],
      ],
    );
  }

  Widget _warningBanner(
      {required IconData icon,
        required String text,
        required Color color,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: DashTheme.radiusSm,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: DashTheme.radiusSm,
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: DashTheme.textPrimary)),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: DashTheme.radiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: DashTheme.radiusMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: DashTheme.radiusMd,
            border: Border.all(color: DashTheme.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated to accept the currency NumberFormat
  Widget _buildRecentOrders(NumberFormat currency) {
    return StreamBuilder<List<Order>>(
      stream: widget.repo.watchRecentOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: GoogleFonts.poppins(fontSize: 12)));
        }
        if (!snapshot.hasData) {
          return const ShimmerList(itemCount: 3);
        }
        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return const EmptyState(
              icon: Icons.receipt_long_rounded, title: 'No recent orders');
        }
        return ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final o = orders[i];
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 18,
                backgroundColor:
                DashTheme.statusColor(o.status).withOpacity(0.12),
                child: Icon(Icons.shopping_bag_rounded,
                    size: 16, color: DashTheme.statusColor(o.status)),
              ),
              title: Text('Order #${o.id}',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(currency.format(o.total),
                  style: GoogleFonts.poppins(
                      fontSize: 11.5, color: DashTheme.textSecondary)),
              trailing: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DashTheme.statusColor(o.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  o.status.displayName,
                  style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: DashTheme.statusColor(o.status)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}