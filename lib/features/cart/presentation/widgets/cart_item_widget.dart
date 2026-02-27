import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../data/models/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  String _formatPrice(double price, String currency) {
    return '$currency ${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPriceDrop = item.priceDropped && item.savingsAmount > 0;
    final bool isUnavailable = !item.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUnavailable
            ? Border.all(color: AppColors.error.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Unavailable warning
          if (isUnavailable)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      LocalizationService.t(context, 'cart.itemUnavailable'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          // Price drop alert
          if (hasPriceDrop && !isUnavailable)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      '${LocalizationService.t(context, 'cart.priceDropped')} ${_formatPrice(item.savingsAmount, item.currency)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          // Main content row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.productImageUrl.isNotEmpty
                    ? Image.network(
                        item.productImageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(width: Spacing.md),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Product name
                    Text(
                      item.productName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isUnavailable
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    // Provider
                    Text(
                      item.provider,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    // Price row
                    Row(
                      children: <Widget>[
                        // Current price
                        Text(
                          _formatPrice(item.currentPrice, item.currency),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isUnavailable
                                    ? Colors.grey[600]
                                    : AppColors.primary,
                              ),
                        ),
                        // Original price if dropped
                        if (hasPriceDrop && !isUnavailable) ...[
                          const SizedBox(width: Spacing.xs),
                          Text(
                            _formatPrice(item.priceWhenAdded, item.currency),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                    // Quantity controls and remove button
                    Row(
                      children: <Widget>[
                        // Quantity selector
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isUnavailable
                                  ? Colors.grey[300]!
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: isUnavailable
                                    ? null
                                    : item.quantity > 1
                                        ? () => onQuantityChanged(
                                              item.quantity - 1,
                                            )
                                        : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                color: isUnavailable
                                    ? Colors.grey[400]
                                    : Colors.black,
                              ),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  '${item.quantity}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: isUnavailable
                                            ? Colors.grey[600]
                                            : Colors.black,
                                      ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: isUnavailable
                                    ? null
                                    : () => onQuantityChanged(
                                          item.quantity + 1,
                                        ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                color: isUnavailable
                                    ? Colors.grey[400]
                                    : Colors.black,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Remove button
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: onRemove,
                          color: AppColors.error,
                          tooltip: LocalizationService.t(context, 'cart.removeItemTooltip'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
