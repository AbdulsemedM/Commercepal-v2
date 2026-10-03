import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/utils/category_image_assets.dart';
import 'package:commercepal/features/categories/data/models/category.dart';

/// Left rail of top-level categories. The selected item sits on the content
/// surface with a brand marker, so it reads as connected to the right pane.
class CategorySidebar extends StatelessWidget {
  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category> onCategorySelected;

  static const double width = 96;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      width: width,
      color: scheme.surfaceContainerHigh,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final Category category = categories[index];
          final bool selected = selectedCategory?.slug == category.slug;
          return Semantics(
            button: true,
            selected: selected,
            child: Material(
              color: selected ? scheme.surface : Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (!selected) HapticFeedback.selectionClick();
                  onCategorySelected(category);
                },
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    PositionedDirectional(
                      start: 0,
                      top: Spacing.sm,
                      bottom: Spacing.sm,
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        width: selected ? 4 : 0,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: const BorderRadiusDirectional.horizontal(
                            end: Radius.circular(3),
                          ).resolve(Directionality.of(context)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: Spacing.sm,
                      ),
                      child: Column(
                        children: <Widget>[
                          _CategoryThumb(category: category),
                          const SizedBox(height: 6),
                          Text(
                            category.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: selected
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryThumb extends StatelessWidget {
  const _CategoryThumb({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool hasNetworkImage =
        category.imageUrl != null && category.imageUrl!.isNotEmpty;
    final String? assetPath =
        CategoryImageAssets.assetPathForName(category.name);
    final Widget fallback = ColoredBox(
      color: scheme.surface,
      child: Icon(
        CategoryImageAssets.iconForName(category.name),
        color: scheme.onSurfaceVariant,
        size: 20,
      ),
    );
    const double size = 44;

    final Widget image = hasNetworkImage
        ? AppNetworkImage(
            url: category.imageUrl!,
            width: size,
            height: size,
            memCacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            errorWidget: assetPath != null
                ? Image.asset(assetPath, fit: BoxFit.cover)
                : fallback,
          )
        : assetPath != null
            ? Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback;

    return ClipOval(child: SizedBox.square(dimension: size, child: image));
  }
}
