import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dash_theme.dart';

/// Animated stat card for the Overview grid. Counts up from 0 on first
/// build instead of just popping the number in — small touch, feels alive.
class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final String? trend; // e.g. "+12% this week"
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: DashTheme.radiusMd,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: DashTheme.radiusMd,
          border: Border.all(color: DashTheme.cardBorder),
          boxShadow: DashTheme.softShadow,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                if (trend != null)
                  Text(
                    trend!,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: DashTheme.success,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) => Text(
                animatedValue.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DashTheme.textPrimary,
                ),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: DashTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Consistent "nothing here" state instead of a bare Text widget.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DashTheme.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: DashTheme.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: DashTheme.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: DashTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder shown while a stream's first snapshot loads.
/// Looks far less jarring than a spinning circle for list-heavy tabs.
class ShimmerList extends StatefulWidget {
  final int itemCount;
  const ShimmerList({super.key, this.itemCount = 4});

  @override
  State<ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<ShimmerList> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.itemCount,
      itemBuilder: (context, i) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final opacity = 0.4 + 0.3 * (1 - (_controller.value - 0.5).abs() * 2);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(opacity * 0.3),
              borderRadius: DashTheme.radiusSm,
            ),
          );
        },
      ),
    );
  }
}

/// Reusable search field used by Products/Orders/Alerts/Tips/Users.
class DashSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const DashSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: DashTheme.textSecondary),
        prefixIcon: const Icon(Icons.search, size: 20, color: DashTheme.textSecondary),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () {
            controller.clear();
            onChanged('');
          },
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: DashTheme.radiusSm,
          borderSide: const BorderSide(color: DashTheme.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DashTheme.radiusSm,
          borderSide: const BorderSide(color: DashTheme.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DashTheme.radiusSm,
          borderSide: const BorderSide(color: DashTheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Section header used above lists ("Recent Orders", "All Products" etc.)
/// with an optional trailing action.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: DashTheme.textPrimary),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A consistent confirm-before-delete dialog so destructive actions never
/// happen on a single accidental tap.
Future<bool> confirmDelete(BuildContext context, String itemLabel) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete $itemLabel?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      content: Text(
        'This action cannot be undone.',
        style: GoogleFonts.poppins(fontSize: 13, color: DashTheme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: GoogleFonts.poppins(color: DashTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: DashTheme.danger, foregroundColor: Colors.white),
          child: Text('Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showDashSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: isError ? DashTheme.danger : DashTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ),
  );
}