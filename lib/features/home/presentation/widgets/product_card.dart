import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/services/localization_service.dart';

/// Grid aspect ratio for two-column product grids (image ≈ square + details).
const double kProductGridAspectRatio = 0.6;

/// Catalogue tile: image with discount badge, two-line title, rating and
/// price. The whole tile is a single tap target opening the product page.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    this.productId,
    required this.imageUrl,
    required this.description,
    required this.price,
    this.product,
    this.currency,
    this.sold,
    this.inStock,
    this.showProgressBar = false,
    this.rating,
    this.reviewCount,
    this.originalPrice,
    this.discountPercentage,
    this.showViewProductButton,
    this.fillCell = false,
    this.imageLoadPriority,
  });

  final String? productId;
  final String imageUrl;
  final String description;

  /// Pre-formatted price ("ETB 1,200.00"). Used only when [product] is null.
  final String price;
  final Product? product;
  final String? currency;
  final int? sold;
  final int? inStock;
  final bool showProgressBar;
  final double? rating;
  final int? reviewCount;

  /// Pre-formatted list price. Used only when [product] is null.
  final String? originalPrice;
  final int? discountPercentage;

  /// Deprecated: tiles are fully tappable; the button is no longer shown.
  final bool? showViewProductButton;

  /// When true, image and content expand to fill the parent (grid cells).
  final bool fillCell;

  /// Lower values load sooner on home (ordered image queue).
  final int? imageLoadPriority;

  static const double _imageFallbackHeight = 160;

  String? get _id {
    final String? id = product?.id ?? productId;
    return (id == null || id.isEmpty) ? null : id;
  }

  void _openProductDetail(BuildContext context) {
    HapticFeedback.selectionClick();
    // Forward what the tile already knows so the detail page can fall back
    // on it when the API returns an empty product record.
    final Map<String, String> query = <String, String>{
      if (_id != null) 'id': _id!,
      if (description.isNotEmpty) 'name': description,
      if (price.isNotEmpty) 'price': price,
      if (imageUrl.isNotEmpty) 'image': imageUrl,
      if ((rating ?? 0) > 0) 'rating': rating!.toString(),
      if ((reviewCount ?? 0) > 0) 'reviews': reviewCount!.toString(),
    };
    context.push(
      Uri(path: AppRoutes.productDetail, queryParameters: query).toString(),
    );
  }

  /// Parses "ETB 1,234.50" / "$12.00" into 1234.5; null when not numeric.
  static num? _parseAmount(String? formatted) {
    if (formatted == null) return null;
    final String digits = formatted.replaceAll(RegExp(r'[^0-9.]'), '');
    if (digits.isEmpty) return null;
    return num.tryParse(digits);
  }

  /// Leading non-numeric part of a pre-formatted price ("ETB", "$").
  static String _parsePrefix(String formatted) {
    final Match? m = RegExp(r'^[^0-9]*').firstMatch(formatted.trim());
    return (m?.group(0) ?? '').trim();
  }

  ({num? amount, num? original, String label}) _resolvePrice() {
    final Product? p = product;
    if (p != null) {
      double? original = p.originalPrice;
      final int? pct = discountPercentage ?? p.discountPercentage;
      if ((original == null || original <= p.price) &&
          pct != null &&
          pct > 0 &&
          pct < 100) {
        original = p.price / (1 - pct / 100);
      }
      final String code = currency ?? p.currency;
      return (
        amount: p.price,
        original: original,
        label: CountryCurrencyConstants.getCurrencySymbol(code),
      );
    }
    return (
      amount: _parseAmount(price),
      original: _parseAmount(originalPrice),
      label: currency != null
          ? CountryCurrencyConstants.getCurrencySymbol(currency!)
          : _parsePrefix(price),
    );
  }

  int? _resolveDiscount(num? amount, num? original) {
    final int? explicit = discountPercentage ?? product?.discountPercentage;
    if (explicit != null && explicit > 0) return explicit;
    if (amount == null || original == null || original <= amount) return null;
    final int pct = (((original - amount) / original) * 100).round();
    return pct >= 1 ? pct : null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool bounded = fillCell || constraints.hasBoundedHeight;
        return _buildCard(context, bounded);
      },
    );
  }

  Widget _buildCard(BuildContext context, bool bounded) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors c = context.commerce;
    final bool isLight = theme.brightness == Brightness.light;

    final ({num? amount, num? original, String label}) resolved =
        _resolvePrice();
    final int? discount = _resolveDiscount(resolved.amount, resolved.original);
    final bool unavailable = product?.isAvailable == false;
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double? stars = (rating ?? product?.rating);
    final int? reviews = reviewCount ?? product?.reviewCount;

    final TextStyle? titleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.5,
      height: 1.3,
      color: scheme.onSurface,
    );

    final Widget priceWidget = resolved.amount != null
        ? PriceTag(
            amount: resolved.amount!,
            currency: resolved.label,
            originalAmount: resolved.original,
            size: PriceTagSize.small,
            showDiscountBadge: false,
            inline: false,
          )
        : Text(
            price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(color: c.price),
          );

    final Widget details = Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Reserve two lines so prices align across a row.
          SizedBox(
            height: scaler.scale(13.5) * 1.3 * 2,
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
          ),
          const SizedBox(height: 4),
          // In rows/grids, reserve the rating and list-price lines even when
          // empty so every tile in a row has the same image size.
          if (bounded)
            SizedBox(
              height: scaler.scale(16),
              child: (stars != null && stars > 0)
                  ? RatingStars(rating: stars, reviewCount: reviews, size: 12)
                  : null,
            )
          else if (stars != null && stars > 0)
            RatingStars(rating: stars, reviewCount: reviews, size: 12),
          const SizedBox(height: 4),
          if (bounded)
            SizedBox(
              height: scaler.scale(36),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: priceWidget,
              ),
            )
          else
            priceWidget,
          if (showProgressBar &&
              sold != null &&
              inStock != null &&
              sold! + inStock! > 0) ...<Widget>[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: LinearProgressIndicator(
                value: sold! / (sold! + inStock!),
                minHeight: 4,
                color: c.deal,
                backgroundColor: c.dealContainer,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${LocalizationService.t(context, 'home.dealOfDay.sold')}: $sold',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    final Widget image = _ProductImage(
      url: imageUrl,
      loadPriority: imageLoadPriority,
      height: bounded ? null : _imageFallbackHeight,
      discount: discount,
      unavailable: unavailable,
    );

    final String semanticPrice = resolved.amount != null
        ? '${resolved.label} ${MoneyFormatter.formatAmount(resolved.amount!)}'
        : price;

    return Semantics(
      button: true,
      label: <String>[
        description,
        semanticPrice,
        if (discount != null) '-$discount%',
        if (stars != null && stars > 0)
          context.tr('rating.semantic', <String, Object?>{
            'rating': stars.toStringAsFixed(1),
            'count': reviews ?? 0,
          }),
      ].join(', '),
      excludeSemantics: true,
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: isLight ? BorderSide(color: c.border) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openProductDetail(context),
          child: bounded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(child: image),
                    details,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[image, details],
                ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.url,
    required this.loadPriority,
    required this.height,
    required this.discount,
    required this.unavailable,
  });

  final String url;
  final int? loadPriority;
  final double? height;
  final int? discount;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final Widget placeholder = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: scheme.outline,
          size: 28,
        ),
      ),
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (url.isNotEmpty)
            AppNetworkImage(
              url: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height ?? double.infinity,
              memCacheWidth: (180 * dpr).round(),
              loadPriority: loadPriority,
              placeholder: const ShimmerLoading(
                borderRadius: BorderRadius.zero,
              ),
              errorWidget: placeholder,
            )
          else
            placeholder,
          if (unavailable)
            ColoredBox(
              color: scheme.surface.withValues(alpha: 0.65),
              child: Center(
                child: AppBadge(
                  label: context.tr('product.outOfStock'),
                  tone: AppBadgeTone.neutral,
                  solid: true,
                  size: AppBadgeSize.medium,
                ),
              ),
            ),
          if (discount != null && !unavailable)
            PositionedDirectional(
              top: 8,
              start: 8,
              child: AppBadge(
                label: context.tr('price.percentOff', <String, Object?>{
                  'percent': discount,
                }),
                tone: AppBadgeTone.deal,
              ),
            ),
        ],
      ),
    );
  }
}
