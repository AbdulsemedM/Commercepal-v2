import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/category_image_assets.dart';
import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/app/router/app_router.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.categoryName,
    required this.subCategories,
    this.isLoading = false,
    this.errorMessage,
  });

  final String categoryName;
  final List<SubCategory> subCategories;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        color: scheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(
                '$categoryName Subcategories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Subcategories grid
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: Spacing.md),
                          Text(
                            errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : subCategories.isEmpty
                  ? Center(
                      child: Text(
                        'No subcategories available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
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
                      itemCount: subCategories.length,
                      itemBuilder: (BuildContext context, int index) {
                        final subCategory = subCategories[index];

                        return _SubCategoryCard(subCategory: subCategory);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryCard extends StatelessWidget {
  const _SubCategoryCard({required this.subCategory});

  final SubCategory subCategory;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final fallbackIcon = CategoryImageAssets.iconForName(subCategory.name);
    final hasNetworkImage =
        subCategory.imageUrl != null && subCategory.imageUrl!.isNotEmpty;
    final assetPath = CategoryImageAssets.assetPathForName(subCategory.name);

    return InkWell(
      onTap: () {
        final query = Uri.encodeComponent(subCategory.name);
        final provider = Uri.encodeComponent(subCategory.providerId);
        context.push(
          '${AppRoutes.productSearch}?query=$query&provider=$provider',
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Subcategory image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withOpacity(0.55),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: hasNetworkImage
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          subCategory.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return assetPath != null
                                ? Image.asset(
                                    assetPath,
                                    fit: BoxFit.cover,
                                  )
                                : _buildPlaceholder(context, fallbackIcon);
                          },
                        ),
                      )
                    : (assetPath != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.asset(
                              assetPath,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return _buildPlaceholder(context, fallbackIcon);
                              },
                            ),
                          )
                        : _buildPlaceholder(context, fallbackIcon)),
              ),
            ),
            // Subcategory name
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Text(
                subCategory.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, IconData icon) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(icon, color: scheme.onSurfaceVariant, size: 40),
      ),
    );
  }
}
