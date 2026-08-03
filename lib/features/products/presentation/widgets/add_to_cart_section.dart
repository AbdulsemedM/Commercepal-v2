import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class AddToCartSection extends StatelessWidget {
  const AddToCartSection({
    super.key,
    required this.isInCart,
    required this.quantity,
    required this.unitPrice,
    required this.onAddToCart,
    required this.onQuantityChanged,
    required this.onToggleFavorite,
    this.isInWishlist = false,
    this.isAddingToCart = false,
    this.canAddToCart = true,
    this.total,
  });

  final bool isInCart;
  final int quantity;
  final String unitPrice;
  final VoidCallback onAddToCart;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onToggleFavorite;
  final bool isInWishlist;
  final bool isAddingToCart;

  /// False when the catalog record is unsellable or has no usable price.
  final bool canAddToCart;

  /// Preformatted line total. Falls back to [unitPrice] when the caller cannot
  /// resolve a numeric price.
  final String? total;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (isInCart) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: quantity > 1
                          ? () => onQuantityChanged(quantity - 1)
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$quantity',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => onQuantityChanged(quantity + 1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  '${LocalizationService.t(context, 'productDetail.total')} ${total ?? unitPrice}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (isAddingToCart || !canAddToCart) ? null : onAddToCart,
                  borderRadius: BorderRadius.circular(999),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: canAddToCart && !isAddingToCart
                          ? AppDecorations.primaryCtaGradient
                          : null,
                      color: canAddToCart && !isAddingToCart
                          ? null
                          : scheme.surfaceContainerHighest,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: isAddingToCart
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              canAddToCart
                                  ? LocalizationService.t(
                                      context,
                                      'productDetail.addToCart',
                                    )
                                  : LocalizationService.t(
                                      context,
                                      'productDetail.unavailable',
                                    ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: canAddToCart
                                    ? Colors.white
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.primary,
                ),
                onPressed: onToggleFavorite,
                padding: const EdgeInsets.all(Spacing.sm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
