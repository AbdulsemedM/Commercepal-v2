import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// Title, rating, price, availability and options — the buy box.
class ProductInfoSection extends StatefulWidget {
  const ProductInfoSection({
    super.key,
    required this.title,
    required this.price,
    required this.currency,
    required this.rating,
    required this.reviewCount,
    required this.code,
    required this.category,
    this.priceText = '',
    this.originalPrice,
    this.storeName,
    this.stockLevel = 0,
    this.stuffStatus,
    this.createdTime,
    this.isSellAllowed = true,
    this.variantSelector,
    this.onRatingTap,
  });

  final String title;

  /// Numeric selling price; when <= 0, [priceText] is shown instead.
  final double price;
  final String currency;

  /// Pre-formatted fallback (e.g. from the tile that opened this page).
  final String priceText;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String code;
  final String category;

  /// Brand or vendor shown above the title.
  final String? storeName;

  /// Units left; 0 means unknown. Low positive values show "Only N left".
  final int stockLevel;
  final String? stuffStatus;
  final String? createdTime;
  final bool isSellAllowed;
  final Widget? variantSelector;
  final VoidCallback? onRatingTap;

  @override
  State<ProductInfoSection> createState() => _ProductInfoSectionState();
}

class _ProductInfoSectionState extends State<ProductInfoSection> {
  static const int _lowStockThreshold = 10;
  bool _titleExpanded = false;

  bool get _isNew {
    final String status = (widget.stuffStatus ?? '').toLowerCase();
    if (status.contains('new')) return true;
    final DateTime? created = DateTime.tryParse(widget.createdTime ?? '');
    if (created == null) return false;
    return DateTime.now().difference(created).inDays <= 30;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors c = context.commerce;
    final String symbol =
        CountryCurrencyConstants.getCurrencySymbol(widget.currency);

    final (IconData stockIcon, String stockText, Color stockColor) =
        !widget.isSellAllowed
            ? (
                Icons.remove_shopping_cart_outlined,
                context.tr('product.outOfStock'),
                scheme.error,
              )
            : (widget.stockLevel > 0 &&
                    widget.stockLevel <= _lowStockThreshold)
                ? (
                    Icons.local_fire_department_outlined,
                    context.tr('product.onlyLeft', <String, Object?>{
                      'count': widget.stockLevel,
                    }),
                    c.warning,
                  )
                : (
                    Icons.check_circle_outline_rounded,
                    context.tr('product.inStock'),
                    c.success,
                  );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.storeName != null && widget.storeName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xxs),
              child: Text(
                widget.storeName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                ),
              ),
            ),
          Semantics(
            header: true,
            child: GestureDetector(
              onTap: () => setState(() => _titleExpanded = !_titleExpanded),
              child: AnimatedSize(
                duration: AppMotion.fast,
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  widget.title,
                  maxLines: _titleExpanded ? null : 3,
                  overflow: _titleExpanded ? null : TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
          if (widget.rating > 0 || widget.reviewCount > 0) ...<Widget>[
            const SizedBox(height: Spacing.xs),
            InkWell(
              onTap: widget.onRatingTap,
              borderRadius: AppRadius.smAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RatingStars(
                      rating: widget.rating,
                      size: 16,
                      reviewCount: null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.tr('product.ratingsCount', <String, Object?>{
                        'count': MoneyFormatter.formatWhole(widget.reviewCount),
                      }),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          if (widget.price > 0)
            PriceTag(
              amount: widget.price,
              currency: symbol,
              originalAmount: widget.originalPrice,
              size: PriceTagSize.large,
            )
          else if (widget.priceText.isNotEmpty)
            Text(widget.priceText, style: theme.textTheme.headlineSmall),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(stockIcon, size: 18, color: stockColor),
                  const SizedBox(width: 4),
                  Text(
                    stockText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: stockColor,
                    ),
                  ),
                ],
              ),
              if (_isNew)
                AppBadge(
                  label: context.tr('product.new'),
                  tone: AppBadgeTone.info,
                  size: AppBadgeSize.medium,
                ),
            ],
          ),
          if (widget.variantSelector != null) ...<Widget>[
            const SizedBox(height: Spacing.md),
            widget.variantSelector!,
          ],
          if (widget.code.isNotEmpty || widget.category.isNotEmpty) ...<Widget>[
            const SizedBox(height: Spacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                child: Column(
                  children: <Widget>[
                    if (widget.code.isNotEmpty)
                      _InfoRow(
                        label: context.tr('productDetail.code'),
                        value: widget.code,
                      ),
                    if (widget.code.isNotEmpty && widget.category.isNotEmpty)
                      const Divider(),
                    if (widget.category.isNotEmpty)
                      _InfoRow(
                        label: context.tr('productDetail.category'),
                        value: widget.category,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
