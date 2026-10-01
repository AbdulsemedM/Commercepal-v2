import 'package:flutter/material.dart';

import '../../services/localization_service.dart';
import '../theme/commerce_colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../utils/money_formatter.dart';
import 'app_badge.dart';

enum PriceTagSize { small, medium, large }

/// Selling price with optional struck-through list price and discount badge.
///
/// Renders Amazon-style: small currency code, prominent whole amount and
/// smaller decimals, so prices scan quickly in dense grids.
class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.amount,
    required this.currency,
    this.originalAmount,
    this.size = PriceTagSize.medium,
    this.showDiscountBadge = true,
    this.inline = true,
    this.color,
  });

  final num amount;
  final String currency;

  /// List price before discount. Ignored unless greater than [amount].
  final num? originalAmount;
  final PriceTagSize size;
  final bool showDiscountBadge;

  /// Original price beside the selling price (true) or underneath (false).
  final bool inline;

  /// Overrides the selling price colour (e.g. white on a banner).
  final Color? color;

  bool get _hasDiscount =>
      originalAmount != null && originalAmount! > amount && amount > 0;

  /// Rounded percentage off, or null when there is no real discount.
  int? get discountPercent {
    if (!_hasDiscount) return null;
    final int pct =
        (((originalAmount! - amount) / originalAmount!) * 100).round();
    return pct >= 1 ? pct : null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommerceColors commerce = context.commerce;
    final Color priceColor = color ?? commerce.price;

    final (double main, double minor, double strike) = switch (size) {
      PriceTagSize.small => (15.0, 10.5, 11.5),
      PriceTagSize.medium => (19.0, 12.0, 12.5),
      PriceTagSize.large => (26.0, 14.0, 14.0),
    };

    final String formatted = MoneyFormatter.formatAmount(amount);
    final int dot = formatted.lastIndexOf('.');
    final String whole = dot == -1 ? formatted : formatted.substring(0, dot);
    final String decimals = dot == -1 ? '' : formatted.substring(dot + 1);
    final String code = currency.trim();

    final TextStyle base =
        (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
      color: priceColor,
      fontWeight: FontWeight.w700,
      height: 1.0,
      fontFeatures: AppTypography.tabularFigures,
    );
    final TextStyle minorStyle = base.copyWith(
      fontSize: minor,
      fontWeight: FontWeight.w600,
    );

    final Widget price = Text.rich(
      TextSpan(
        children: <InlineSpan>[
          if (code.isNotEmpty)
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 2),
                child: Text(code, style: minorStyle),
              ),
            ),
          TextSpan(text: whole, style: base.copyWith(fontSize: main)),
          if (decimals.isNotEmpty && decimals != '00')
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: Text(decimals, style: minorStyle),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
    );

    final int? pct = discountPercent;
    final Widget? original = _hasDiscount
        ? Text(
            MoneyFormatter.format(originalAmount!, code),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: strike,
              color: commerce.priceOriginal,
              decoration: TextDecoration.lineThrough,
              decorationColor: commerce.priceOriginal,
              fontFeatures: AppTypography.tabularFigures,
            ),
          )
        : null;
    final Widget? badge = (showDiscountBadge && pct != null)
        ? AppBadge(
            label: context.tr('price.percentOff', <String, Object?>{
              'percent': pct,
            }),
            tone: AppBadgeTone.deal,
            size: size == PriceTagSize.large
                ? AppBadgeSize.medium
                : AppBadgeSize.small,
          )
        : null;

    final String semantic = <String>[
      MoneyFormatter.format(amount, code),
      if (_hasDiscount)
        '${context.tr('price.was')} ${MoneyFormatter.format(originalAmount!, code)}',
      if (pct != null)
        context.tr('price.percentOff', <String, Object?>{'percent': pct}),
    ].join(', ');

    final Widget body = inline
        ? Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 2,
            children: <Widget>[
              price,
              if (original != null) original,
              if (badge != null) badge,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              price,
              if (original != null || badge != null) ...<Widget>[
                const SizedBox(height: AppRadius.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (badge != null) badge,
                    if (badge != null && original != null)
                      const SizedBox(width: 6),
                    if (original != null) Flexible(child: original),
                  ],
                ),
              ],
            ],
          );

    return Semantics(
      label: semantic,
      excludeSemantics: true,
      child: body,
    );
  }
}
