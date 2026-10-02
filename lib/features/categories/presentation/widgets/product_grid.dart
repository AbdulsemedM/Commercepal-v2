import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/utils/category_image_assets.dart';
import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/features/categories/presentation/widgets/category_top_picks.dart';
import 'package:commercepal/services/localization_service.dart';

/// Right pane of the Categories tab — a mini storefront for the selected
/// category: hero card with "Shop all", a "Shop by type" grid of
/// subcategories, and a row of top picks from the catalogue.
class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.categoryName,
    required this.subCategories,
    this.isLoading = false,
    this.errorMessage,
    this.imageUrl,
  });

  final String categoryName;
  final List<SubCategory> subCategories;
  final bool isLoading;
  final String? errorMessage;

  /// Category image for the hero (falls back to a bundled asset / icon).
  final String? imageUrl;

  static void _search(BuildContext context, String term) {
    HapticFeedback.selectionClick();
    context.push(
      '${AppRoutes.productSearch}?query=${Uri.encodeComponent(term.trim())}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

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
    } else {
      body = CustomScrollView(
        // Fresh scroll position per category.
        key: PageStorageKey<String>('cat_$categoryName'),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.sm,
                Spacing.sm,
                Spacing.sm,
                Spacing.md,
              ),
              child: _CategoryHero(
                name: categoryName,
                imageUrl: imageUrl,
                count: subCategories.length,
                onShopAll: () => _search(context, categoryName),
              ),
            ),
          ),
          if (subCategories.isEmpty)
            SliverToBoxAdapter(
              child: AppEmptyState(
                compact: true,
                icon: Icons.category_outlined,
                title: context.tr('home.categories.noSubcategories'),
              ),
            )
          else ...<Widget>[
            SliverToBoxAdapter(
              child: SectionHeader(
                title: context.tr('categories.shopByType'),
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.sm,
                Spacing.xs,
                Spacing.sm,
                Spacing.lg,
              ),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: Spacing.sm,
                  crossAxisSpacing: Spacing.xs,
                  childAspectRatio: 0.74,
                ),
                itemCount: subCategories.length,
                itemBuilder: (BuildContext context, int i) => _SubCategoryTile(
                  subCategory: subCategories[i],
                  onTap: () => _search(context, subCategories[i].name),
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: CategoryTopPicks(
              query: categoryName,
              title: context.tr('categories.topPicks', <String, Object?>{
                'name': categoryName,
              }),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: Spacing.xl + MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      );
    }

    return Expanded(
      child: ColoredBox(
        color: scheme.surface,
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          child: KeyedSubtree(
            key: ValueKey<String>(categoryName),
            child: body,
          ),
        ),
      ),
    );
  }
}

/// Category banner: image with a dark scrim, name, type count, Shop all.
class _CategoryHero extends StatelessWidget {
  const _CategoryHero({
    required this.name,
    required this.count,
    required this.onShopAll,
    this.imageUrl,
  });

  final String name;
  final int count;
  final String? imageUrl;
  final VoidCallback onShopAll;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? asset = CategoryImageAssets.assetPathForName(name);
    final bool hasUrl = imageUrl != null && imageUrl!.isNotEmpty;

    final Widget brandFill = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[
            AppColors.maroon,
            Color.lerp(AppColors.maroon, Colors.black, 0.35)!,
          ],
        ),
      ),
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Icon(
            CategoryImageAssets.iconForName(name),
            size: 56,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
      ),
    );

    final Widget image = asset != null
        ? Image.asset(
            asset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => brandFill,
          )
        : hasUrl
            ? AppNetworkImage(
                url: imageUrl!,
                width: double.infinity,
                height: double.infinity,
                errorWidget: brandFill,
              )
            : brandFill;

    // Photo on top, solid brand strip below: text stays legible no matter
    // how busy the category photo is.
    return Semantics(
      container: true,
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(aspectRatio: 2, child: image),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: <Color>[
                    AppColors.maroon,
                    Color.lerp(AppColors.maroon, Colors.black, 0.3)!,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  Spacing.md,
                  Spacing.sm,
                  Spacing.sm,
                  Spacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Semantics(
                            header: true,
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (count > 0)
                            Text(
                              context.tr('categories.typesCount',
                                  <String, Object?>{'count': count}),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: onShopAll,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.maroon,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                        ),
                        textStyle: theme.textTheme.labelLarge,
                      ),
                      child: Text(context.tr('categories.shopAllShort')),
                    ),
                  ],
                ),
              ),
            ),
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
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: context.commerce.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AspectRatio(aspectRatio: 1, child: image),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Center(
                    child: Text(
                      subCategory.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
