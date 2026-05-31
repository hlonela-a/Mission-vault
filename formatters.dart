// lib/core/utils/formatters.dart

import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, {String symbol = '\$'}) {
    final f = NumberFormat('#,##0.00', 'en_US');
    return '$symbol${f.format(amount)}';
  }

  static String compactCurrency(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String date(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  static String dateShort(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd MMM').format(dt);
  }

  static String dateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '—';
    if (start == null) return '→ ${date(end)}';
    if (end == null) return '${date(start)} →';
    return '${dateShort(start)} – ${date(end)}';
  }

  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  static String daysRemaining(DateTime? departure) {
    if (departure == null) return '—';
    final diff = departure.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Departed';
    if (diff == 0) return 'Today';
    if (diff == 1) return '1 day';
    return '$diff days';
  }

  static double budgetUsedPercent(double allocated, double spent) {
    if (allocated <= 0) return 0;
    return (spent / allocated).clamp(0.0, 1.0);
  }
}
