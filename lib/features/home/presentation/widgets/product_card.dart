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

    final Widget imageSection = _buildImageSection(context, scheme);

    final Widget detailsSection = Padding(
      padding: EdgeInsets.fromLTRB(
        widget.fillCell ? Spacing.xs : Spacing.sm,
        widget.fillCell ? Spacing.xs : Spacing.sm,
        widget.fillCell ? Spacing.xs : Spacing.sm,
        widget.fillCell ? 4 : Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () => _openProductDetail(context),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? scheme.onSurface : AppColors.navy,
                        fontSize: widget.fillCell ? 11 : 13,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: widget.fillCell ? 2 : 4),
                if (widget.rating != null && widget.rating! > 0) ...[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.star,
                        color: AppColors.secondary,
                        size: widget.fillCell ? 11 : 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.rating!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: widget.fillCell ? 10 : 12,
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
                              fontSize: widget.fillCell ? 9 : 11,
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: widget.fillCell ? 2 : Spacing.xs),
                ],
                Text(
                  widget.price,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: widget.fillCell ? 12 : 15,
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
                      fontSize: widget.fillCell ? 9 : 11,
                      decoration: TextDecoration.lineThrough,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          if (widget.showProgressBar &&
              widget.sold != null &&
              widget.inStock != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              'Sold: ${widget.sold} In Stock: ${widget.inStock}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: Spacing.xs),
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
          if (_canAddToCart) ...[
            SizedBox(height: widget.fillCell ? 4 : Spacing.xs),
            SizedBox(
              width: double.infinity,
              height: widget.fillCell ? 28 : 32,
              child: FilledButton(
                onPressed: _isAdding ? null : _handleAddToCart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.onSecondary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isAdding
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onSecondary.withValues(alpha: 0.8),
                        ),
                      )
                    : Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: widget.fillCell ? 9 : 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
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
      child: widget.fillCell
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

  Widget _buildImageSection(BuildContext context, ColorScheme scheme) {
    final double fixedHeight = widget.fillCell ? double.infinity : 150;

    return InkWell(
      onTap: () => _openProductDetail(context),
      child: Stack(
        fit: widget.fillCell ? StackFit.expand : StackFit.loose,
        children: <Widget>[
          Container(
            height: widget.fillCell ? null : fixedHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: widget.fillCell
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
                    height: widget.fillCell ? double.infinity : fixedHeight,
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
                    fontSize: widget.fillCell ? 8 : 10,
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
          size: widget.fillCell ? 28 : 40,
        ),
      ),
    );
  }
}
