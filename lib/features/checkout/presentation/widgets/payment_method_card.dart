import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/features/checkout/data/models/payment_method_assets.dart';

class PaymentMethodCard extends StatefulWidget {
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

  /// Soft pulsing glow to draw attention (e.g. QPay).
  final bool glow;

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _glowController;
  Animation<double>? _glowAnimation;

  @override
  void initState() {
    super.initState();
    _syncGlowAnimation();
  }

  @override
  void didUpdateWidget(covariant PaymentMethodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.glow != widget.glow) {
      _syncGlowAnimation();
    }
  }

  void _syncGlowAnimation() {
    if (widget.glow) {
      _glowController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat(reverse: true);
      _glowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
        CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
      );
    } else {
      _glowController?.stop();
      _glowController?.dispose();
      _glowController = null;
      _glowAnimation = null;
    }
  }

  @override
  void dispose() {
    _glowController?.dispose();
    super.dispose();
  }

  /// Branded fallback icon per method when no usable logo exists.
  IconData get _fallbackIcon {
    if (widget.icon != null) return widget.icon!;
    final String key =
        '${widget.paymentMethodId} ${widget.paymentMethodName}'.toLowerCase();
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

    final Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
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
                    id: widget.paymentMethodId,
                    name: widget.paymentMethodName,
                    iconUrl: widget.iconUrl,
                    fallback: fallback,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  widget.paymentMethodName,
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
    );

    if (!widget.glow || _glowAnimation == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: widget.isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          boxShadow: AppDecorations.softCardShadow(),
        ),
        clipBehavior: Clip.antiAlias,
        child: card,
      );
    }

    return AnimatedBuilder(
      animation: _glowAnimation!,
      builder: (BuildContext context, Widget? child) {
        final double t = _glowAnimation!.value;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.pink.withValues(alpha: 0.45 + (t * 0.4)),
              width: widget.isSelected ? 2.5 : 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.25 + (t * 0.35)),
                blurRadius: 10 + (t * 14),
                spreadRadius: 1 + (t * 2),
                offset: Offset.zero,
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12 + (t * 0.18)),
                blurRadius: 6 + (t * 8),
                spreadRadius: 0,
                offset: Offset.zero,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: card,
    );
  }
}
