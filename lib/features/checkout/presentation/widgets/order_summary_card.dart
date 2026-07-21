import 'package:flutter/material.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../../cart/data/models/cart.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.cart,
  });

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppDecorations.softCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.t(context, 'checkout.orderSummary'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
          ),
          const SizedBox(height: Spacing.md),
          ...cart.items.asMap().entries.map((entry) {
            final int index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.productImageUrl.isNotEmpty
                        ? Image.network(
                            item.productImageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return _imageFallback(index);
                            },
                          )
                        : _imageFallback(index),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.navy,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} × ${MoneyFormatter.format(item.unitPrice, item.currency)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    MoneyFormatter.format(item.subtotal, item.currency),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: Spacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizationService.t(context, 'checkout.subtotal'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                MoneyFormatter.format(cart.subtotal, cart.currency),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizationService.t(context, 'checkout.total'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
              ),
              Text(
                MoneyFormatter.format(cart.estimatedTotal, cart.currency),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(int index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppDecorations.accentGradientAt(index),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
