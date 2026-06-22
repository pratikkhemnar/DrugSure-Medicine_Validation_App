import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../drugsure_ecommerce/models/order_model.dart';
import '../dash_theme.dart';
import '../dashboard_repository.dart';
import '../widgets/dash_widgets.dart';

class OrdersTab extends StatefulWidget {
  final DashboardRepository repo;
  const OrdersTab({super.key, required this.repo});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  OrderStatus? _statusFilter; // null = "All"
  String? _updatingOrderId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(Order order, OrderStatus newStatus) async {
    setState(() => _updatingOrderId = order.id);
    try {
      await widget.repo.updateOrderStatus(
        orderDocId: order.id,
        orderDisplayId: order.id,
        newStatus: newStatus,
        userId: order.userId,
      );

      if (!mounted) return;
      showDashSnackBar(context, 'Order #${order.id} marked ${newStatus.displayName}');
    } catch (e) {
      if (!mounted) return;
      showDashSnackBar(context, 'Update failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _updatingOrderId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Column(
      children: [
        Container(
          color: DashTheme.bgLight,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: DashSearchBar(
            controller: _searchCtrl,
            hint: 'Search by order ID...',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        _buildStatusChips(),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<Order>>(
            stream: widget.repo.watchOrders(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const ShimmerList();

              var orders = snapshot.data!;
              if (_statusFilter != null) {
                orders = orders.where((o) => o.status == _statusFilter).toList();
              }
              if (_query.isNotEmpty) {
                orders = orders.where((o) => o.id.toLowerCase().contains(_query.toLowerCase())).toList();
              }

              if (orders.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: _query.isEmpty && _statusFilter == null ? 'No orders yet' : 'No orders match your filters',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (context, i) => _orderCard(orders[i], currency),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChips() {
    // 'pending' isn't shown as its own filter chip since fresh orders are
    // saved as 'placed' — keeping the chip row focused on real lifecycle
    // stages a customer actually sees.
    const statuses = [
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.shipped,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
      OrderStatus.cancelled,
    ];

    return Container(
      height: 44,
      color: DashTheme.bgLight,
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _statusChip(null, 'All'),
          ...statuses.map((s) => _statusChip(s, s.displayName)),
        ],
      ),
    );
  }

  Widget _statusChip(OrderStatus? status, String label) {
    final selected = _statusFilter == status;
    final color = status == null ? DashTheme.primary : DashTheme.statusColor(status);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: GoogleFonts.poppins(fontSize: 11.5, color: selected ? Colors.white : DashTheme.textPrimary)),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = status),
        selectedColor: color,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: DashTheme.cardBorder)),
      ),
    );
  }

  Widget _orderCard(Order order, NumberFormat currency) {
    final isUpdating = _updatingOrderId == order.id;
    final statusColor = DashTheme.statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DashTheme.radiusMd,
        border: Border.all(color: DashTheme.cardBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.12),
            radius: 20,
            child: Icon(Icons.shopping_bag_rounded, color: statusColor, size: 18),
          ),
          title: Text('Order #${order.id}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(
            '${currency.format(order.total)}  •  ${DateFormat('dd MMM yyyy').format(order.createdAt)}',
            style: GoogleFonts.poppins(fontSize: 11.5, color: DashTheme.textSecondary),
          ),
          trailing: isUpdating
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : SizedBox(
            width: 150,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<OrderStatus>(
                value: order.status,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                style: GoogleFonts.poppins(fontSize: 11.5, color: statusColor, fontWeight: FontWeight.w600),
                items: OrderStatus.values
                    .where((s) => s != OrderStatus.pending) // internal-only state, not admin-selectable
                    .map<DropdownMenuItem<OrderStatus>>(
                      (s) => DropdownMenuItem<OrderStatus>(value: s, child: Text(s.displayName, overflow: TextOverflow.ellipsis)),
                )
                    .toList(),
                onChanged: (newStatus) {
                  if (newStatus != null && newStatus != order.status) {
                    _updateStatus(order, newStatus);
                  }
                },
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text('ITEMS', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: DashTheme.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  if (order.items.isEmpty)
                    Text('No item details available', style: GoogleFonts.poppins(fontSize: 12, color: DashTheme.textSecondary))
                  else
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.medicineName} × ${item.quantity}',
                              style: GoogleFonts.poppins(fontSize: 12.5),
                            ),
                          ),
                          Text(currency.format(item.totalPrice), style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                  const SizedBox(height: 10),
                  Text('SHIPPING ADDRESS', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: DashTheme.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    order.deliveryAddress.addressLine1.isEmpty ? 'No address on file' : order.deliveryAddress.displayAddress,
                    style: GoogleFonts.poppins(fontSize: 12.5),
                  ),
                  const SizedBox(height: 10),
                  Text('PAYMENT', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: DashTheme.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    order.paymentMethod.isEmpty ? 'N/A' : order.paymentMethod,
                    style: GoogleFonts.poppins(fontSize: 12.5),
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