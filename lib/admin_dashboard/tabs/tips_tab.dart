import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dash_theme.dart';
import '../dashboard_repository.dart';
import '../model/dashboard_models.dart';
import '../widgets/dash_widgets.dart';

class TipsTab extends StatefulWidget {
  final DashboardRepository repo;
  const TipsTab({super.key, required this.repo});

  @override
  State<TipsTab> createState() => _TipsTabState();
}

class _TipsTabState extends State<TipsTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String _query = '';
  bool _submitting = false;
  bool _formExpanded = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repo.addTip(title: _titleCtrl.text.trim(), subtitle: _subtitleCtrl.text.trim());
      _titleCtrl.clear();
      _subtitleCtrl.clear();
      if (mounted) {
        showDashSnackBar(context, 'Tip posted successfully');
        setState(() => _formExpanded = false);
      }
    } catch (e) {
      if (mounted) showDashSnackBar(context, 'Failed to post tip: $e', isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete(TipItem tip) async {
    final confirmed = await confirmDelete(context, 'this tip');
    if (!confirmed) return;
    try {
      await widget.repo.deleteDocument('tips', tip.id);
      if (mounted) showDashSnackBar(context, 'Tip deleted');
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
          child: StreamBuilder<List<TipItem>>(
            stream: widget.repo.watchTips(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const ShimmerList();

              var tips = snapshot.data!;
              if (_query.isNotEmpty) {
                tips = tips
                    .where((t) =>
                t.title.toLowerCase().contains(_query.toLowerCase()) ||
                    t.subtitle.toLowerCase().contains(_query.toLowerCase()))
                    .toList();
              }
              if (tips.isEmpty) {
                return EmptyState(
                  icon: Icons.lightbulb_outline_rounded,
                  title: _query.isEmpty ? 'No health tips yet' : 'No tips match "$_query"',
                  subtitle: _query.isEmpty ? 'Tap "New Tip" above to post one' : null,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tips.length,
                itemBuilder: (context, i) => _tipCard(tips[i]),
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
                child: DashSearchBar(controller: _searchCtrl, hint: 'Search tips...', onChanged: (v) => setState(() => _query = v)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => setState(() => _formExpanded = !_formExpanded),
                icon: Icon(_formExpanded ? Icons.close : Icons.add, size: 18),
                label: Text(_formExpanded ? 'Close' : 'New Tip', style: GoogleFonts.poppins(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _formExpanded ? Colors.grey.shade300 : DashTheme.primary,
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
            TextFormField(
              controller: _titleCtrl,
              validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Tip Title',
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(borderRadius: DashTheme.radiusSm),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subtitleCtrl,
              maxLines: 2,
              validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Tip Description',
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(borderRadius: DashTheme.radiusSm),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_rounded, size: 18),
                label: Text(_submitting ? 'Posting...' : 'POST TIP', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashTheme.primary,
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

  Widget _tipCard(TipItem tip) {
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
          decoration: BoxDecoration(color: DashTheme.warning.withOpacity(0.12), shape: BoxShape.circle),
          child: const Icon(Icons.lightbulb_rounded, color: DashTheme.warning, size: 20),
        ),
        title: Text(tip.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(tip.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: DashTheme.danger, size: 22),
          onPressed: () => _delete(tip),
        ),
      ),
    );
  }
}