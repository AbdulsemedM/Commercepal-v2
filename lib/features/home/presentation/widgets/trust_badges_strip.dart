import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';

/// Compact trust badges strip mirroring commercepal.com footer highlights.
class TrustBadgesStrip extends StatelessWidget {
  const TrustBadgesStrip({super.key});

  static const List<_TrustItem> _items = <_TrustItem>[
    _TrustItem(
      icon: Icons.local_shipping_outlined,
      title: 'Free Shipping',
      subtitle: 'Invoices over 5000 ETB',
    ),
    _TrustItem(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Cash Back',
      subtitle: 'Pay with Owallet',
    ),
    _TrustItem(
      icon: Icons.support_agent_outlined,
      title: '24/7 Support',
      subtitle: 'We\'re here to help',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? scheme.surfaceContainerLow : AppColors.cream,
          borderRadius: AppDecorations.cardBorderRadius,
          boxShadow: isDark ? null : AppDecorations.softCardShadow(),
        ),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < _items.length; i++) ...[
              if (i > 0)
                Container(
                  width: 1,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              Expanded(child: _TrustBadgeTile(item: _items[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrustItem {
  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _TrustBadgeTile extends StatelessWidget {
  const _TrustBadgeTile({required this.item});

  final _TrustItem item;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color titleColor =
        isDark ? Theme.of(context).colorScheme.onSurface : AppColors.navy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          item.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: titleColor,
                fontSize: 11,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          item.subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 9,
                height: 1.2,
              ),
        ),
      ],
    );
  }
}
