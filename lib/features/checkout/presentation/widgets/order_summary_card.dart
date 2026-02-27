import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.t(context, 'checkout.orderSummary'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: Spacing.md),
          // Product list
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: Row(
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
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
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} × ${item.currency} ${item.unitPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Subtotal
                    Text(
                      '${item.currency} ${item.subtotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              )),
          const Divider(height: Spacing.lg),
          // Summary totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizationService.t(context, 'checkout.subtotal'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '${cart.currency} ${cart.subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
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
                    ),
              ),
              Text(
                '${cart.currency} ${cart.estimatedTotal.toStringAsFixed(2)}',
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
}
