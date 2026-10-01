import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/checkout/data/models/payment_method_assets.dart';
import 'package:commercepal/services/localization_service.dart';

/// Payment method row: logo, name, optional description and a radio mark.
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.isSelected,
    required this.onTap,
    this.description,
    this.icon,
    this.iconUrl,
    this.glow = false,
  });

  final String paymentMethodId;
  final String paymentMethodName;
  final IconData? icon;
  final String? iconUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final String? description;

  /// Highlight this method (e.g. QPay) with a "Featured" badge.
  final bool glow;

  /// Branded fallback icon per method when no usable logo exists.
  IconData get _fallbackIcon {
    if (icon != null) return icon!;
    final String key = '$paymentMethodId $paymentMethodName'.toLowerCase();
    if (key.contains('cash')) return Icons.payments_outlined;
    if (key.contains('card') || key.contains('visa') || key.contains('master')) {
      return Icons.credit_card_outlined;
    }
    if (key.contains('wallet')) return Icons.account_balance_wallet_outlined;
    if (key.contains('qpay') || key.contains('bank')) {
      return Icons.account_balance_outlined;
    }
    if (key.contains('birr') ||
        key.contains('pesa') ||
        key.contains('airtel') ||
        key.contains('amole') ||
        key.contains('tele')) {
      return Icons.phone_android_outlined;
    }
    return Icons.payment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: isSelected,
      button: true,
      label: paymentMethodName,
      excludeSemantics: true,
      child: Material(
        color: isSelected ? scheme.primaryContainer : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(
            color: isSelected ? scheme.primary : context.commerce.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.smAll,
                    border: Border.all(color: context.commerce.border),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: AppRadius.xsAll,
                    child: PaymentMethodAssets.logo(
                      size: 36,
                      id: paymentMethodId,
                      name: paymentMethodName,
                      iconUrl: iconUrl,
                      fallback: Icon(
                        _fallbackIcon,
                        color: AppColors.maroon,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: Spacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            paymentMethodName,
                            style: theme.textTheme.titleSmall,
                          ),
                          if (glow)
                            AppBadge(
                              label: context.tr('checkout.featured'),
                              tone: AppBadgeTone.deal,
                              icon: Icons.bolt_rounded,
                            ),
                        ],
                      ),
                      if (description != null && description!.isNotEmpty)
                        Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                AnimatedSwitcher(
                  duration: AppMotion.fast,
                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey<bool>(isSelected),
                    color: isSelected ? scheme.primary : scheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
