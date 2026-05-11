import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/app/router/app_router.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    this.productId,
    required this.imageUrl,
    required this.description,
    required this.price,
    this.sold,
    this.inStock,
    this.showProgressBar = false,
    this.rating,
    this.reviewCount,
    this.originalPrice,
    this.discountPercentage,
  });

  final String? productId;
  final String imageUrl;
  final String description;
  final String price;
  final int? sold;
  final int? inStock;
  final bool showProgressBar;
  final double? rating;
  final int? reviewCount;
  final String? originalPrice;
  final int? discountPercentage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        // Navigate with product ID if available, otherwise use name and price
        if (productId != null && productId!.isNotEmpty) {
          context.push(
            '${AppRoutes.productDetail}?id=${Uri.encodeComponent(productId!)}',
          );
        } else {
          context.push(
            '${AppRoutes.productDetail}?name=${Uri.encodeComponent(description)}&price=${Uri.encodeComponent(price)}',
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Product image placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
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
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  : _buildPlaceholder(context),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Product description
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Rating
                  if (rating != null && rating! > 0) ...[
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (reviewCount != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '($reviewCount)',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                  ],
                  // Price with discount
                  Row(
                    children: [
                      if (originalPrice != null) ...[
                        Text(
                          originalPrice!,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          price,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: originalPrice != null
                                    ? AppColors.error
                                    : scheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (discountPercentage != null && discountPercentage! > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '-$discountPercentage%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (showProgressBar && sold != null && inStock != null) ...[
                    const SizedBox(height: Spacing.xs),
                    // Sold/In Stock info
                    Text(
                      'Sold: $sold In Stock: $inStock',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: sold! / (sold! + inStock!),
                        backgroundColor:
                            scheme.surfaceContainerHighest.withOpacity(0.8),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
          size: 40,
        ),
      ),
    );
  }
}

