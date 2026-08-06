import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/widgets/app_network_image.dart';
import 'package:commercepal/features/products/data/models/product.dart';

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
  final String price;
  final Product? product;
  final String? currency;
  final int? sold;
  final int? inStock;
  final bool showProgressBar;
  final double? rating;
  final int? reviewCount;
  final String? originalPrice;
  final int? discountPercentage;
  final bool? showViewProductButton;
  /// When true, image and content expand to fill the parent (grid cells).
  final bool fillCell;
  /// Lower values load sooner on home (ordered image queue).
  final int? imageLoadPriority;

  bool get _showViewProductButton {
    if (showViewProductButton == false) return false;
    final String? id = product?.id ?? productId;
    return id != null && id.isNotEmpty;
  }

  void _openProductDetail(BuildContext context) {
    final String? id = product?.id ?? productId;
    // Always forward what the card already knows so the detail page can fall
    // back on it when the API returns an empty product record.
    final Map<String, String> query = <String, String>{
      if (id != null && id.isNotEmpty) 'id': id,
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

  void _handleViewProductTap(BuildContext context) {
    if (!_showViewProductButton) return;
    HapticFeedback.selectionClick();
    _openProductDetail(context);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool bounded = fillCell || constraints.hasBoundedHeight;
        return _buildCard(context, scheme, isDark, bounded);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
    bool bounded,
  ) {
    // Compact metrics when height is constrained (home rows / grid cells).
    final bool compact = bounded;
    final double pad = compact ? Spacing.xs : Spacing.sm;
    final double titleSize = compact ? 12.5 : 14.5;
    final double priceSize = compact ? 13 : 15;
    final double originalSize = compact ? 9 : 11;
    final double buttonHeight = compact ? 30 : 36;
    final double buttonFont = compact ? 10 : 12;

    final Widget imageSection = _buildImageSection(
      context,
      scheme,
      expand: compact,
    );

    final Widget titleAndRating = InkWell(
      onTap: () => _openProductDetail(context),
      borderRadius: BorderRadius.circular(8),
      child: Text(
        description,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? scheme.onSurface : AppColors.navy,
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    // Discounted price stacked above the crossed-out original, then the
    // star rating with review count underneath.
    final Widget priceSection = InkWell(
      onTap: () => _openProductDetail(context),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildPriceText(context, isDark, priceSize),
          if (originalPrice != null) ...[
            const SizedBox(height: 1),
            Text(
              originalPrice!,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: originalSize,
                height: 1.1,
                decoration: TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
          if ((rating != null && rating! > 0) ||
              (reviewCount != null && reviewCount! > 0)) ...[
            const SizedBox(height: 2),
            Row(
              children: <Widget>[
                Icon(
                  Icons.star,
                  color: AppColors.secondary,
                  size: compact ? 12 : 14,
                ),
                const SizedBox(width: 2),
                Text(
                  (rating != null && rating! > 0)
                      ? rating!.toStringAsFixed(1)
                      : '—',
                  style: TextStyle(
                    fontSize: compact ? 10 : 12,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (reviewCount != null) ...[
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      '(${reviewCount})',
                      style: TextStyle(
                        fontSize: compact ? 9 : 11,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    final Widget textBlock = InkWell(
      onTap: () => _openProductDetail(context),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          titleAndRating,
          const SizedBox(height: 2),
          priceSection,
          if (showProgressBar &&
              sold != null &&
              inStock != null) ...[
            const SizedBox(height: 4),
            Text(
              'Sold: ${sold} In Stock: ${inStock}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: sold! / (sold! + inStock!),
                backgroundColor:
                    scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.success,
                ),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );

    final Widget? viewProductButton = _showViewProductButton
        ? SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: FilledButton(
              onPressed: () => _handleViewProductTap(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'View Product',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: buttonFont,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        : null;

    final Widget detailsSection = Padding(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: titleSize * 1.15 * 2,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: titleAndRating,
                  ),
                ),
                const SizedBox(height: 4),
                priceSection,
                if (viewProductButton != null) ...[
                  const SizedBox(height: 6),
                  viewProductButton,
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                textBlock,
                if (viewProductButton != null) ...[
                  const SizedBox(height: Spacing.xs),
                  viewProductButton,
                ],
              ],
            ),
    );

    return Container(
      decoration: AppDecorations.elevatedCard(
        background: isDark ? scheme.surfaceContainerLow : Colors.white,
        shadowColor: scheme.shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: imageSection),
                detailsSection,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                imageSection,
                detailsSection,
              ],
            ),
    );
  }

  /// Price like the web: currency prefix in pink, amount in navy.
  Widget _buildPriceText(BuildContext context, bool isDark, double priceSize) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color amountColor = isDark ? scheme.onSurface : AppColors.navy;

    final String priceText = this.price.trim();
    final int splitIndex = priceText.indexOf(' ');
    final String prefix =
        splitIndex > 0 ? priceText.substring(0, splitIndex) : '';
    final String amount =
        splitIndex > 0 ? priceText.substring(splitIndex + 1) : priceText;

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          if (prefix.isNotEmpty)
            TextSpan(
              text: '$prefix ',
              style: TextStyle(
                color: AppColors.pink,
                fontWeight: FontWeight.w700,
                fontSize: priceSize - 2,
              ),
            ),
          TextSpan(
            text: amount,
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w800,
              fontSize: priceSize,
            ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: const TextStyle(height: 1.15),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    ColorScheme scheme, {
    required bool expand,
  }) {
    final double fixedHeight = 150;

    return InkWell(
      onTap: () => _openProductDetail(context),
      child: Stack(
        fit: expand ? StackFit.expand : StackFit.loose,
        children: <Widget>[
          Container(
            height: expand ? null : fixedHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: expand
                  ? null
                  : const BorderRadius.only(
                      topLeft: Radius.circular(AppDecorations.radiusMd),
                      topRight: Radius.circular(AppDecorations.radiusMd),
                    ),
            ),
            child: imageUrl.isNotEmpty
                ? AppNetworkImage(
                    url: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: expand ? double.infinity : fixedHeight,
                    memCacheWidth: (150 *
                            MediaQuery.devicePixelRatioOf(context))
                        .round(),
                    memCacheHeight: (fixedHeight *
                            MediaQuery.devicePixelRatioOf(context))
                        .round(),
                    loadPriority: imageLoadPriority,
                    placeholder: _buildPlaceholder(context),
                    errorWidget: _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
          ),
          if (discountPercentage != null &&
              discountPercentage! > 0)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: expand ? 6 : 8,
                  vertical: expand ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${discountPercentage}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: expand ? 10 : 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image,
          color: scheme.onSurfaceVariant,
          size: 28,
        ),
      ),
    );
  }
}
