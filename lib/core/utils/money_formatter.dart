import 'package:intl/intl.dart';

/// Formats money amounts with thousands separator (#,###.##).
/// Use everywhere product prices and totals are displayed.
class MoneyFormatter {
  MoneyFormatter._();

  static final NumberFormat _amountFormat = NumberFormat('#,##0.00');
  static final NumberFormat _wholeFormat = NumberFormat('#,##0');

  /// Formats a numeric amount with thousands separator (e.g. 1899.99 → "1,899.99").
  static String formatAmount(num amount) {
    return _amountFormat.format(amount);
  }

  /// Formats a whole number with thousands separator (e.g. 1000 → "1,000"). Use for counts or integer prices.
  static String formatWhole(num amount) {
    return _wholeFormat.format(amount);
  }

  /// Formats amount with currency prefix (e.g. "ETB 1,899.99").
  static String format(num amount, String currency) {
    final code = currency.trim();
    if (code.isEmpty) return formatAmount(amount);
    return '$code ${formatAmount(amount)}';
  }
}
