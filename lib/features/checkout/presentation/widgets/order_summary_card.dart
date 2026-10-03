import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../../cart/data/models/cart.dart';
import '../../../cart/data/models/cart_item.dart';

/// Items + totals for review before payment. Long orders collapse to the
/// first [collapsedCount] lines.
class OrderSummaryCard extends StatefulWidget {
  const OrderSummaryCard({
    super.key,
    required this.cart,
    this.collapsedCount = 3,
  });

  final Cart cart;
  final int collapsedCount;

  @override
  State<OrderSummaryCard> createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Cart cart = widget.cart;
    final String symbol =
        CountryCurrencyConstants.getCurrencySymbol(cart.currency);
    final bool canCollapse = cart.items.length > widget.collapsedCount;
    final List<CartItem> visible = _expanded || !canCollapse
        ? cart.items
        : cart.items.take(widget.collapsedCount).toList();
    final int units =
        cart.items.fold(0, (int sum, CartItem i) => sum + i.quantity);

    Widget totalRow(String label, num amount, {bool strong = false}) {
      final TextStyle? style = strong
          ? theme.textTheme.titleMedium
          : theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label, style: style)),
            Text(
              MoneyFormatter.format(amount, symbol),
              style: style?.copyWith(
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        context.tr('checkout.orderSummary'),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Text(
                    context.tr('checkout.itemsCount', <String, Object?>{
                      'count': units,
                    }),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              AnimatedSize(
                duration: AppMotion.medium,
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    for (final CartItem item in visible)
                      _SummaryLine(item: item, symbol: symbol),
                  ],
                ),
              ),
              if (canCollapse)
                AppButton.text(
                  label: _expanded
                      ? context.tr('product.showLess')
                      : context.tr('checkout.showAllItems', <String, Object?>{
                          'count': cart.items.length,
                        }),
                  trailingIcon: _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              const Divider(height: Spacing.lg),
              totalRow(context.tr('checkout.subtotal'), cart.subtotal),
              if (cart.totalSavings > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          context.tr('checkout.savings'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.commerce.success,
                          ),
                        ),
                      ),
                      Text(
                        '−${MoneyFormatter.format(cart.totalSavings, symbol)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.commerce.success,
                          fontFeatures: AppTypography.tabularFigures,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: Spacing.xxs),
              totalRow(
                context.tr('checkout.total'),
                cart.estimatedTotal,
                strong: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.item, required this.symbol});

  final CartItem item;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Widget fallback = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Icon(Icons.shopping_bag_outlined, color: scheme.outline, size: 20),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: SizedBox.square(
              dimension: 52,
              child: item.productImageUrl.isNotEmpty
                  ? AppNetworkImage(
                      url: item.productImageUrl,
                      width: 52,
                      height: 52,
                      memCacheWidth:
                          (52 * MediaQuery.devicePixelRatioOf(context)).round(),
                      errorWidget: fallback,
                    )
                  : fallback,
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
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '${item.quantity} × ${MoneyFormatter.format(item.unitPrice, symbol)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            MoneyFormatter.format(item.subtotal, symbol),
            style: theme.textTheme.labelLarge?.copyWith(
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}
