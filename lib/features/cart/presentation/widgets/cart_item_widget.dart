import 'package:flutter/material.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
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
    return MoneyFormatter.format(price, currency);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool hasPriceDrop = item.priceDropped && item.savingsAmount > 0;
    final bool isUnavailable = !item.isAvailable;
    final int gradientSeed = item.id.abs() % AppDecorations.accentGradients.length;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUnavailable
            ? Border.all(color: AppColors.error.withOpacity(0.3), width: 1)
            : null,
        boxShadow: AppDecorations.softCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                  const Icon(
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
                  const Icon(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.productImageUrl.isNotEmpty
                    ? Image.network(
                        item.productImageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return _imageFallback(gradientSeed);
                        },
                      )
                    : _imageFallback(gradientSeed),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.productName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isUnavailable
                                ? scheme.onSurfaceVariant
                                : AppColors.navy,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.provider,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: <Widget>[
                        Text(
                          _formatPrice(item.currentPrice, item.currency),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isUnavailable
                                    ? scheme.onSurfaceVariant
                                    : AppColors.primary,
                              ),
                        ),
                        if (hasPriceDrop && !isUnavailable) ...[
                          const SizedBox(width: Spacing.xs),
                          Text(
                            _formatPrice(item.priceWhenAdded, item.currency),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  decoration: TextDecoration.lineThrough,
                                ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: AppDecorations.softCream,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: isUnavailable
                                    ? null
                                    : item.quantity > 1
                                        ? () => onQuantityChanged(
                                              item.quantity - 1,
                                            )
                                        : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 30,
                                ),
                                color: isUnavailable
                                    ? scheme.onSurfaceVariant
                                    : AppColors.primary,
                              ),
                              Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  '${item.quantity}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: isUnavailable
                                            ? scheme.onSurfaceVariant
                                            : AppColors.navy,
                                      ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: isUnavailable
                                    ? null
                                    : () => onQuantityChanged(
                                          item.quantity + 1,
                                        ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 30,
                                ),
                                color: isUnavailable
                                    ? scheme.onSurfaceVariant
                                    : AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 22),
                          onPressed: onRemove,
                          color: AppColors.error,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          tooltip: LocalizationService.t(
                            context,
                            'cart.removeItemTooltip',
                          ),
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

  Widget _imageFallback(int gradientSeed) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppDecorations.accentGradientAt(gradientSeed),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
