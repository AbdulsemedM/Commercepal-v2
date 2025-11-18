import 'package:flutter/material.dart';
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
  });

  final bool isInCart;
  final int quantity;
  final String unitPrice;
  final VoidCallback onAddToCart;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onToggleFavorite;

  String _calculateTotal() {
    // For testing, just return a simple number
    return '\$2,900';
  }

  @override
  Widget build(BuildContext context) {
    if (isInCart) {
      // Quantity selector state
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
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
            // Total price
            Expanded(
              child: Text(
                '${LocalizationService.t(context, 'productDetail.total')} ${_calculateTotal()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    } else {
      // Add to Cart button state
      return Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            // Add to Cart button
            Expanded(
              child: FilledButton(
                onPressed: onAddToCart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                ),
                child: Text(
                  LocalizationService.t(context, 'productDetail.addToCart'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.md),
            // Heart icon
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: AppColors.primary,
                ),
                onPressed: onToggleFavorite,
                padding: const EdgeInsets.all(Spacing.sm),
              ),
            ),
          ],
        ),
      );
    }
  }
}

