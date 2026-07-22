import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
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
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            )
                          : _buildRows(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRows(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < subCategories.length; i += 2) {
      final bool isLastOdd =
          i == subCategories.length - 1 && subCategories.length.isOdd;
      if (isLastOdd) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: SizedBox(
              height: 150,
              child: _SubCategoryCard(
                subCategory: subCategories[i],
                gradientIndex: i,
                fullWidth: true,
              ),
            ),
          ),
        );
      } else {
        final SubCategory left = subCategories[i];
        final SubCategory? right =
            i + 1 < subCategories.length ? subCategories[i + 1] : null;
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: SizedBox(
              height: 150,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _SubCategoryCard(
                      subCategory: left,
                      gradientIndex: i,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: right != null
                        ? _SubCategoryCard(
                            subCategory: right,
                            gradientIndex: i + 1,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        Spacing.md,
      ),
      children: rows,
    );
  }
}

class _SubCategoryCard extends StatelessWidget {
  const _SubCategoryCard({
    required this.subCategory,
    required this.gradientIndex,
    this.fullWidth = false,
  });

  final SubCategory subCategory;
  final int gradientIndex;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = CategoryImageAssets.iconForName(subCategory.name);
    final hasNetworkImage =
        subCategory.imageUrl != null && subCategory.imageUrl!.isNotEmpty;
    final String? assetPath =
        CategoryImageAssets.assetPathForName(subCategory.name);
    final gradient = AppDecorations.accentGradientAt(gradientIndex);

    Widget imageBody() {
      // Nested folder assets: assets/images/subcategories/{parent}/{slug}.jpg
      final String? path = assetPath;
      if (path != null &&
          path.contains('/subcategories/') &&
          path.split('/subcategories/').last.contains('/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            if (!hasNetworkImage) return _buildIconBody(fallbackIcon);
            return Image.network(
              subCategory.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => _buildIconBody(fallbackIcon),
            );
          },
        );
      }
      if (hasNetworkImage) {
        return Image.network(
          subCategory.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
              _buildIconBody(fallbackIcon),
        );
      }
      return _buildIconBody(fallbackIcon);
    }

    return InkWell(
      onTap: () {
        // Keep spaces/punctuation in the display name; encode for the route only.
        final query = Uri.encodeComponent(subCategory.name.trim());
        context.push('${AppRoutes.productSearch}?query=$query');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppDecorations.softCardShadow(),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: gradient),
                child: imageBody(),
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: fullWidth ? Spacing.md : Spacing.sm,
                vertical: Spacing.sm,
              ),
              child: Text(
                subCategory.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBody(IconData icon) {
    return Center(
      child: Icon(icon, color: Colors.white, size: fullWidth ? 48 : 40),
    );
  }
}
