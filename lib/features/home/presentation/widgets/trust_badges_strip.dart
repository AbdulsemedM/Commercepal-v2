import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// Shopping guarantees (shipping, cash back, support) as a quiet info row.
class TrustBadgesStrip extends StatelessWidget {
  const TrustBadgesStrip({super.key});

  static const List<(IconData, String, String)> _items =
      <(IconData, String, String)>[
    (
      Icons.local_shipping_outlined,
      'home.trust.shippingTitle',
      'home.trust.shippingSubtitle',
    ),
    (
      Icons.account_balance_wallet_outlined,
      'home.trust.cashbackTitle',
      'home.trust.cashbackSubtitle',
    ),
    (
      Icons.support_agent_outlined,
      'home.trust.supportTitle',
      'home.trust.supportSubtitle',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.md,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < _items.length; i++) ...<Widget>[
                  if (i > 0) VerticalDivider(color: scheme.outlineVariant),
                  Expanded(
                    child: MergeSemantics(
                      child: Column(
                        children: <Widget>[
                          Icon(_items[i].$1, size: 24, color: scheme.primary),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            context.tr(_items[i].$2),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr(_items[i].$3),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
