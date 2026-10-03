import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// Sticky purchase bar on the product page.
///
/// Not in cart: [wishlist] · Buy now · Add to cart.
/// In cart: "In your cart" confirmation · View cart.
class AddToCartSection extends StatelessWidget {
  const AddToCartSection({
    super.key,
    required this.isInCart,
    required this.onAddToCart,
    this.onToggleFavorite,
    this.onBuyNow,
    this.onViewCart,
    this.isInWishlist = false,
    this.isAddingToCart = false,
    this.canAddToCart = true,
    this.total,
    this.quantity = 1,
  });

  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback? onBuyNow;
  final VoidCallback? onViewCart;
  /// Optional wishlist toggle; hidden when null (e.g. shown on the gallery).
  final VoidCallback? onToggleFavorite;
  final bool isInWishlist;
  final bool isAddingToCart;

  /// False when the catalog record is unsellable or has no usable price.
  final bool canAddToCart;

  /// Pre-formatted total for the current selection, shown above the buttons
  /// when more than one unit is selected.
  final String? total;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors c = context.commerce;

    final Widget wishlist = IconButton.outlined(
      tooltip: context.tr(
        isInWishlist ? 'product.removeFromWishlist' : 'product.addToWishlist',
      ),
      isSelected: isInWishlist,
      onPressed: onToggleFavorite,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(AppSizes.buttonLg),
        side: BorderSide(color: scheme.outline),
      ),
      icon: const Icon(Icons.favorite_border_rounded),
      selectedIcon: Icon(Icons.favorite_rounded, color: scheme.primary),
    );

    final Widget content;
    if (isInCart) {
      content = Row(
        children: <Widget>[
          Icon(Icons.check_circle_rounded, color: c.success),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              context.tr('product.inYourCart'),
              style: theme.textTheme.titleSmall?.copyWith(color: c.success),
            ),
          ),
          AppButton.primary(
            label: context.tr('product.viewCart'),
            trailingIcon: Icons.arrow_forward_rounded,
            fullWidth: false,
            onPressed: onViewCart,
          ),
        ],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (canAddToCart && total != null && quantity > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Row(
                children: <Widget>[
                  Text(
                    context.tr('product.itemsSelected', <String, Object?>{
                      'count': quantity,
                    }),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    total!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: <Widget>[
              if (onToggleFavorite != null) ...<Widget>[
                wishlist,
                const SizedBox(width: Spacing.xs),
              ],
              if (canAddToCart && onBuyNow != null) ...<Widget>[
                Expanded(
                  child: AppButton.secondary(
                    label: context.tr('product.buyNow'),
                    onPressed: isAddingToCart ? null : onBuyNow,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
              ],
              Expanded(
                child: AppButton.primary(
                  label: canAddToCart
                      ? context.tr('productDetail.addToCart')
                      : context.tr('productDetail.unavailable'),
                  loading: isAddingToCart,
                  onPressed: canAddToCart ? onAddToCart : null,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter,
            Spacing.sm,
            Spacing.gutter,
            Spacing.sm,
          ),
          child: AnimatedSwitcher(
            duration: AppMotion.medium,
            child: KeyedSubtree(
              key: ValueKey<bool>(isInCart),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
