import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:commercepal/core/design_system.dart';

/// Status pill used by order history, summary and tracking so every order
/// state reads with the same colour everywhere.
///
/// Tone mapping (by keyword in the raw stage / category string):
/// - cancelled / failed / refunded / rejected → error
/// - delivered / completed / paid → success
/// - shipped / in transit / out for delivery / ongoing → info
/// - pending / processing / packed / confirmed / waiting → warning
/// - anything else → neutral
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.size = AppBadgeSize.medium,
  });

  /// Raw stage or category from the API (e.g. `SHIPPED`, `delivered`).
  final String status;

  /// Text shown in the badge (already localised or provided by the API).
  final String label;
  final AppBadgeSize size;

  static AppBadgeTone toneFor(String status) {
    final String s = status.toUpperCase().replaceAll(RegExp(r'[\s-]'), '_');
    if (s.isEmpty) return AppBadgeTone.neutral;
    bool has(String k) => s.contains(k);
    if (has('CANCEL') || has('FAIL') || has('REFUND') || has('REJECT')) {
      return AppBadgeTone.error;
    }
    if (has('DELIVERED') ||
        has('COMPLETE') ||
        (has('PAID') && !has('UNPAID'))) {
      return AppBadgeTone.success;
    }
    if (has('SHIPPED') ||
        has('TRANSIT') ||
        has('OUT_FOR_DELIVERY') ||
        has('DISPATCH') ||
        has('ONGOING')) {
      return AppBadgeTone.info;
    }
    if (has('PENDING') ||
        has('PROCESS') ||
        has('PACKED') ||
        has('CONFIRM') ||
        has('WAITING')) {
      return AppBadgeTone.warning;
    }
    return AppBadgeTone.neutral;
  }

  /// First of [candidates] whose tone is not neutral (most specific wins),
  /// or the first non-empty one.
  static String pickStatus(List<String> candidates) {
    for (final String c in candidates) {
      if (toneFor(c) != AppBadgeTone.neutral) return c;
    }
    return candidates.firstWhere((String c) => c.isNotEmpty, orElse: () => '');
  }

  static IconData? iconFor(AppBadgeTone tone) => switch (tone) {
        AppBadgeTone.success => Icons.check_circle_rounded,
        AppBadgeTone.info => Icons.local_shipping_rounded,
        AppBadgeTone.warning => Icons.schedule_rounded,
        AppBadgeTone.error => Icons.cancel_rounded,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final AppBadgeTone tone = toneFor(status);
    return Semantics(
      liveRegion: true,
      child: AppBadge(
        label: label,
        tone: tone,
        size: size,
        icon: iconFor(tone),
      ),
    );
  }
}

/// Formats [date] with [pattern] in the current app locale, falling back to
/// the default locale when intl has no data for it.
String formatOrderDate(BuildContext context, DateTime date, String pattern) {
  try {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat(pattern, locale).format(date);
  } catch (_) {
    try {
      return DateFormat(pattern).format(date);
    } catch (_) {
      return date.toIso8601String();
    }
  }
}
