import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/features/checkout/data/models/payment_method_assets.dart';

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
  });

  final String paymentMethodId;
  final String paymentMethodName;
  final IconData? icon;
  final String? iconUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final String? description;

  /// Branded fallback icon per method when no usable logo exists.
  IconData get _fallbackIcon {
    if (icon != null) return icon!;
    final String key = '$paymentMethodId $paymentMethodName'.toLowerCase();
    if (key.contains('cash')) return Icons.shopping_bag_outlined;
    if (key.contains('card') ||
        key.contains('visa') ||
        key.contains('master')) {
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
    final Widget fallback = Icon(
      _fallbackIcon,
      color: AppColors.primary,
      size: 26,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: AppDecorations.softCardShadow(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppDecorations.softCream,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: PaymentMethodAssets.logo(
                      size: 40,
                      id: paymentMethodId,
                      name: paymentMethodName,
                      iconUrl: iconUrl,
                      fallback: fallback,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    paymentMethodName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
