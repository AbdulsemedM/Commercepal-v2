import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/app/router/app_router.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.categoryKey,
  });

  final String categoryKey;

  static const Map<String, List<String>> categoryProducts = <String, List<String>>{
    'categories.technology': <String>[
      'products.smartphones',
      'products.headphones',
      'products.smartwatches',
      'products.tablets',
      'products.laptops',
      'products.desktops',
      'products.powerbanks',
      'products.iosPhones',
    ],
    'categories.realEstate': <String>[],
    'categories.watch': <String>[],
    'categories.homeLife': <String>[],
    'categories.cosmeticSurgery': <String>[],
    'categories.fashion': <String>[],
    'categories.homeAppliances': <String>[],
    'categories.jewelry': <String>[],
    'categories.babyProducts': <String>[],
    'categories.sporting': <String>[],
  };

  @override
  Widget build(BuildContext context) {
    final String categoryName =
        LocalizationService.t(context, categoryKey);
    final List<String> products =
        categoryProducts[categoryKey] ?? <String>[];

    return Expanded(
      child: Container(
        color: AppColors.lightGrey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(
                '$categoryName ${LocalizationService.t(context, 'categories.products')}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Product grid
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(
                        'No products available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(Spacing.md),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: Spacing.md,
                        mainAxisSpacing: Spacing.md,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: products.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String productKey = products[index];
                        final String productName =
                            LocalizationService.t(context, productKey);

                        return _ProductCard(
                          productName: productName,
                          imageUrl: '',
                          productKey: productKey,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.productName,
    required this.imageUrl,
    required this.productKey,
  });

  final String productName;
  final String imageUrl;
  final String productKey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          '${AppRoutes.productDetail}?name=${Uri.encodeComponent(productName)}&price=\$904.18',
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          // Product image placeholder
          Expanded(
            child: Container(
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
          ),
          // Product name
          Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: Text(
              productName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
              textAlign: TextAlign.center,
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

