import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/app/router/app_router.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.description,
    required this.price,
    this.sold,
    this.inStock,
    this.showProgressBar = false,
  });

  final String imageUrl;
  final String description;
  final String price;
  final int? sold;
  final int? inStock;
  final bool showProgressBar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          '${AppRoutes.productDetail}?name=${Uri.encodeComponent(description)}&price=${Uri.encodeComponent(price)}',
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                color: AppColors.lightGrey,
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
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return _buildPlaceholder();
                        },
                      ),
                    )
                  : _buildPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Product description
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.xs),
                  // Price
                  Text(
                    price,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                  ),
                  if (showProgressBar && sold != null && inStock != null) ...[
                    const SizedBox(height: Spacing.xs),
                    // Sold/In Stock info
                    Text(
                      'Sold: $sold In Stock: $inStock',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: sold! / (sold! + inStock!),
                        backgroundColor: Colors.grey[200],
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

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }
}

