import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../dash_theme.dart';
import '../dashboard_repository.dart';
import '../model/dashboard_models.dart';
import '../widgets/dash_widgets.dart';

class AlertsTab extends StatefulWidget {
  final DashboardRepository repo;
  const AlertsTab({super.key, required this.repo});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String _query = '';
  bool _submitting = false;
  bool _formExpanded = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    _dateCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repo.addAlert(
        title: _titleCtrl.text.trim(),
        message: _msgCtrl.text.trim(),
        date: _dateCtrl.text.trim().isEmpty ? DateFormat('dd MMM yyyy').format(DateTime.now()) : _dateCtrl.text.trim(),
      );
      _titleCtrl.clear();
      _msgCtrl.clear();
      _dateCtrl.clear();
      if (mounted) {
        showDashSnackBar(context, 'Alert posted successfully');
        setState(() => _formExpanded = false);
      }
    } catch (e) {
      if (mounted) showDashSnackBar(context, 'Failed to post alert: $e', isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete(AlertItem alert) async {
    final confirmed = await confirmDelete(context, 'this alert');
    if (!confirmed) return;
    try {
      await widget.repo.deleteDocument('alerts', alert.id);
      if (mounted) showDashSnackBar(context, 'Alert deleted');
    } catch (e) {
      if (mounted) showDashSnackBar(context, 'Failed to delete: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<AlertItem>>(
            stream: widget.repo.watchAlerts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const ShimmerList();
              }
              var alerts = snapshot.data!;
              if (_query.isNotEmpty) {
                alerts = alerts
                    .where((a) =>
                a.title.toLowerCase().contains(_query.toLowerCase()) ||
                    a.message.toLowerCase().contains(_query.toLowerCase()))
                    .toList();
              }
              if (alerts.isEmpty) {
                return EmptyState(
                  icon: Icons.notifications_off_rounded,
                  title: _query.isEmpty ? 'No alerts posted yet' : 'No alerts match "$_query"',
                  subtitle: _query.isEmpty ? 'Tap "New Alert" above to post one' : null,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: alerts.length,
                itemBuilder: (context, i) => _alertCard(alerts[i]),
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
                child: DashSearchBar(
                  controller: _searchCtrl,
                  hint: 'Search alerts...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => setState(() => _formExpanded = !_formExpanded),
                icon: Icon(_formExpanded ? Icons.close : Icons.add, size: 18),
                label: Text(_formExpanded ? 'Close' : 'New Alert', style: GoogleFonts.poppins(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _formExpanded ? Colors.grey.shade300 : DashTheme.danger,
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

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(_titleCtrl, 'Alert Title', validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
            const SizedBox(height: 8),
            _field(_msgCtrl, 'Alert Message', maxLines: 2, validator: (v) => v == null || v.trim().isEmpty ? 'Message is required' : null),
            const SizedBox(height: 8),
            _field(_dateCtrl, 'Date Label (optional)', hint: 'e.g., Today — defaults to current date'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_submitting ? 'Posting...' : 'POST ALERT', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashTheme.danger,
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

  Widget _field(TextEditingController c, String label, {int maxLines = 1, String? hint, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        border: OutlineInputBorder(borderRadius: DashTheme.radiusSm),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _alertCard(AlertItem alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DashTheme.radiusMd,
        border: Border.all(color: DashTheme.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: DashTheme.danger.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.campaign_rounded, color: DashTheme.danger, size: 20),
        ),
        title: Text(alert.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12)),
              const SizedBox(height: 4),
              Text(alert.date, style: GoogleFonts.poppins(fontSize: 10, color: DashTheme.textSecondary)),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: DashTheme.danger, size: 22),
          onPressed: () => _delete(alert),
        ),
      ),
    );
  }
}