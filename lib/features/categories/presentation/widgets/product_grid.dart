import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/utils/category_image_assets.dart';
import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/services/localization_service.dart';

/// Right pane of the Categories tab: title, "Shop all" link and a 3-column
/// grid of subcategory tiles.
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

  void _search(BuildContext context, String term) {
    // Keep spaces/punctuation in the display name; encode for the route only.
    context.push(
      '${AppRoutes.productSearch}?query=${Uri.encodeComponent(term.trim())}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final Widget body;
    if (isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      body = AppEmptyState(
        compact: true,
        isError: true,
        icon: Icons.error_outline_rounded,
        title: errorMessage!,
      );
    } else if (subCategories.isEmpty) {
      body = AppEmptyState(
        compact: true,
        icon: Icons.category_outlined,
        title: context.tr('home.categories.noSubcategories'),
        primaryLabel: context.tr('categories.shopAll', <String, Object?>{
          'name': categoryName,
        }),
        onPrimary: () => _search(context, categoryName),
      );
    } else {
      body = GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          Spacing.sm,
          0,
          Spacing.sm,
          Spacing.xl,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: Spacing.sm,
          crossAxisSpacing: Spacing.xs,
          childAspectRatio: 0.72,
        ),
        itemCount: subCategories.length,
        itemBuilder: (BuildContext context, int i) => _SubCategoryTile(
          subCategory: subCategories[i],
          onTap: () => _search(context, subCategories[i].name),
        ),
      );
    }

    return Expanded(
      child: ColoredBox(
        color: scheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                Spacing.sm,
                Spacing.md,
                Spacing.xxs,
                Spacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        categoryName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  if (subCategories.isNotEmpty)
                    AppButton.text(
                      label: context.tr('common.seeAll'),
                      size: AppButtonSize.small,
                      onPressed: () => _search(context, categoryName),
                    ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryTile extends StatelessWidget {
  const _SubCategoryTile({required this.subCategory, required this.onTap});

  final SubCategory subCategory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool hasNetworkImage =
        subCategory.imageUrl != null && subCategory.imageUrl!.isNotEmpty;
    final String? path = CategoryImageAssets.assetPathForName(subCategory.name);
    final Widget fallback = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Icon(
        CategoryImageAssets.iconForName(subCategory.name),
        color: scheme.onSurfaceVariant,
        size: 28,
      ),
    );

    Widget network() => AppNetworkImage(
          url: subCategory.imageUrl!,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: (120 * MediaQuery.devicePixelRatioOf(context)).round(),
          errorWidget: fallback,
        );

    final Widget image;
    // Nested folder assets: assets/images/subcategories/{parent}/{slug}.jpg
    if (path != null &&
        path.contains('/subcategories/') &&
        path.split('/subcategories/').last.contains('/')) {
      image = Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => hasNetworkImage ? network() : fallback,
      );
    } else if (hasNetworkImage) {
      image = network();
    } else {
      image = fallback;
    }

    return Semantics(
      button: true,
      label: subCategory.name,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: image,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subCategory.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
