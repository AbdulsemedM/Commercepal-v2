import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../data/models/cart_item.dart';

/// One cart line: image, title, price (with price-drop savings), quantity.
class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    this.busy = false,
    this.onTap,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  /// Disables the stepper while an update for this line is in flight.
  final bool busy;
  final VoidCallback? onTap;

  static const double _imageSize = 88;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors c = context.commerce;
    final bool unavailable = !item.isAvailable;
    final bool priceDrop = item.priceDropped && item.savingsAmount > 0;
    final String symbol = CountryCurrencyConstants.getCurrencySymbol(
      item.currency,
    );

    final Widget fallback = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Icon(Icons.shopping_bag_outlined, color: scheme.outline),
    );

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Opacity(
                opacity: unavailable ? 0.5 : 1,
                child: ClipRRect(
                  borderRadius: AppRadius.smAll,
                  child: SizedBox.square(
                    dimension: _imageSize,
                    child: item.productImageUrl.isNotEmpty
                        ? AppNetworkImage(
                            url: item.productImageUrl,
                            width: _imageSize,
                            height: _imageSize,
                            memCacheWidth: (_imageSize *
                                    MediaQuery.devicePixelRatioOf(context))
                                .round(),
                            errorWidget: fallback,
                          )
                        : fallback,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: unavailable
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                    if (item.provider.isNotEmpty)
                      Text(
                        item.provider,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: Spacing.xs),
                    if (unavailable)
                      AppBadge(
                        label: context.tr('cart.itemUnavailable'),
                        tone: AppBadgeTone.error,
                        icon: Icons.block_rounded,
                        size: AppBadgeSize.medium,
                      )
                    else ...<Widget>[
                      PriceTag(
                        amount: item.currentPrice,
                        currency: symbol,
                        originalAmount: priceDrop ? item.priceWhenAdded : null,
                        size: PriceTagSize.small,
                        showDiscountBadge: false,
                      ),
                      if (priceDrop)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: AppBadge(
                            label: context.tr('cart.priceDropSaved', <String, Object?>{
                              'amount': MoneyFormatter.format(
                                item.savingsAmount,
                                symbol,
                              ),
                            }),
                            tone: AppBadgeTone.success,
                            icon: Icons.trending_down_rounded,
                          ),
                        ),
                    ],
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: <Widget>[
                        if (unavailable)
                          AppButton(
                            label: context.tr('cart.remove'),
                            variant: AppButtonVariant.destructive,
                            size: AppButtonSize.small,
                            icon: Icons.delete_outline_rounded,
                            fullWidth: false,
                            onPressed: onRemove,
                          )
                        else
                          QuantityStepper(
                            compact: true,
                            value: item.quantity,
                            busy: busy,
                            onChanged: onQuantityChanged,
                            onRemove: onRemove,
                          ),
                        const Spacer(),
                        if (!unavailable && item.quantity > 1)
                          Text(
                            MoneyFormatter.format(
                              item.currentPrice * item.quantity,
                              symbol,
                            ),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: c.price,
                              fontFeatures: AppTypography.tabularFigures,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
