import 'package:flutter/material.dart';

import '../drugsure_ecommerce/models/order_model.dart';

/// All dashboard colors and shared paddings live here.
/// Change a color once, it updates everywhere — no more hunting
/// through 5 files for `Colors.teal.shade800`.
class DashTheme {
  static const primary = Color(0xFF0D9488); // teal 600
  static const primaryDark = Color(0xFF115E59); // teal 800
  static const primaryLight = Color(0xFF5EEAD4); // teal 200

  static const bgLight = Color(0xFFF8FAFC);
  static const cardBorder = Color(0xFFE2E8F0);

  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);
  static const purple = Color(0xFF9333EA);

  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);

  static BoxDecoration get headerGradient => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryDark, primary],
    ),
  );

  static Color statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return success;
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        return info;
      case OrderStatus.confirmed:
        return warning;
      case OrderStatus.cancelled:
        return danger;
      case OrderStatus.placed:
      case OrderStatus.pending:
        return textSecondary;
    }
  }

  static BorderRadius get radiusMd => BorderRadius.circular(14);
  static BorderRadius get radiusSm => BorderRadius.circular(8);

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}