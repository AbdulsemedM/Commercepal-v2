import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/products/data/models/product.dart';

class ProductCard extends StatefulWidget {
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
    this.showAddToCart,
    this.fillCell = false,
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
  final bool? showAddToCart;
  /// When true, image and content expand to fill the parent (grid cells).
  final bool fillCell;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String _cachedCountry = CountryCurrencyConstants.defaultCountryCode;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    final country = await Storage().getSelectedCountry();
    if (mounted) {
      setState(() => _cachedCountry = country);
    }
  }

  bool get _canAddToCart {
    if (widget.showAddToCart == false) return false;
    final id = widget.product?.id ?? widget.productId;
    return id != null && id.isNotEmpty;
  }

  String get _resolvedCurrency =>
      widget.currency ??
      widget.product?.currency ??
      CountryCurrencyConstants.defaultCurrencyCode;

  void _openProductDetail(BuildContext context) {
    final id = widget.product?.id ?? widget.productId;
    if (id != null && id.isNotEmpty) {
      context.push(
        '${AppRoutes.productDetail}?id=${Uri.encodeComponent(id)}',
      );
    } else {
      context.push(
        '${AppRoutes.productDetail}?name=${Uri.encodeComponent(widget.description)}&price=${Uri.encodeComponent(widget.price)}',
      );
    }
  }

  void _handleAddToCart() {
    if (_isAdding || !_canAddToCart) return;

    final id = widget.product?.id ?? widget.productId!;
    HapticFeedback.lightImpact();
    setState(() => _isAdding = true);

    context.read<CartBloc>().add(
          CartAddItemRequested(
            productId: id,
            configId: '',
            quantity: 1,
            currency: _resolvedCurrency,
            country: _cachedCountry,
            product: widget.product,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isAdding = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool bounded =
            widget.fillCell || constraints.hasBoundedHeight;
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
    final double titleSize = compact ? 11 : 13;
    final double priceSize = compact ? 13 : 15;
    final double originalSize = compact ? 9 : 11;
    final double buttonHeight = compact ? 28 : 32;
    final double buttonFont = compact ? 9 : 11;

    final Widget imageSection = _buildImageSection(
      context,
      scheme,
      expand: compact,
    );

    final Widget textBlock = InkWell(
      onTap: () => _openProductDetail(context),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? scheme.onSurface : AppColors.navy,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          if (widget.rating != null && widget.rating! > 0) ...[
            Row(
              children: <Widget>[
                Icon(
                  Icons.star,
                  color: AppColors.secondary,
                  size: compact ? 11 : 14,
                ),
                const SizedBox(width: 2),
                Text(
                  widget.rating!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: compact ? 10 : 12,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.reviewCount != null) ...[
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      '(${widget.reviewCount})',
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
            const SizedBox(height: 2),
          ],
          Text(
            widget.price,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: priceSize,
                  height: 1.15,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (widget.originalPrice != null) ...[
            const SizedBox(height: 1),
            Text(
              widget.originalPrice!,
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
          if (widget.showProgressBar &&
              widget.sold != null &&
              widget.inStock != null) ...[
            const SizedBox(height: 4),
            Text(
              'Sold: ${widget.sold} In Stock: ${widget.inStock}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.sold! / (widget.sold! + widget.inStock!),
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

    final Widget? addButton = _canAddToCart
        ? SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: FilledButton(
              onPressed: _isAdding ? null : _handleAddToCart,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isAdding
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onSecondary.withValues(alpha: 0.8),
                      ),
                    )
                  : Text(
                      'Add to Cart',
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
              children: <Widget>[
                // Shrink/clip text if space is tight; button stays pinned.
                Flexible(
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: textBlock,
                    ),
                  ),
                ),
                if (addButton != null) ...[
                  const SizedBox(height: 4),
                  addButton,
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                textBlock,
                if (addButton != null) ...[
                  const SizedBox(height: Spacing.xs),
                  addButton,
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
                Expanded(flex: 52, child: imageSection),
                Expanded(flex: 48, child: detailsSection),
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
            child: widget.imageUrl.isNotEmpty
                ? Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: expand ? double.infinity : fixedHeight,
                    cacheWidth: (MediaQuery.sizeOf(context).width *
                            MediaQuery.devicePixelRatioOf(context) /
                            2)
                        .round(),
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return _buildPlaceholder(context);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  )
                : _buildPlaceholder(context),
          ),
          if (widget.discountPercentage != null &&
              widget.discountPercentage! > 0)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '-${widget.discountPercentage}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: expand ? 8 : 10,
                    fontWeight: FontWeight.bold,
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
