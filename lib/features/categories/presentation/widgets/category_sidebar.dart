import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/categories/data/models/category.dart';
import 'package:commercepal/core/utils/category_image_assets.dart';

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

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 120,
      color: scheme.surfaceContainerLow,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final Category category = categories[index];
          final bool isSelected = selectedCategory?.slug == category.slug;
          final hasNetworkImage =
              category.imageUrl != null && category.imageUrl!.isNotEmpty;
          final assetPath = CategoryImageAssets.assetPathForName(category.name);
          final fallbackIcon = CategoryImageAssets.iconForName(category.name);

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            child: InkWell(
              onTap: () => onCategorySelected(category),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 34,
                        height: 34,
                        child: hasNetworkImage
                            ? Image.network(
                                category.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => assetPath != null
                                    ? Image.asset(
                                        assetPath,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Icon(
                                          fallbackIcon,
                                          color: isSelected
                                              ? Colors.white
                                              : scheme.onSurfaceVariant,
                                          size: 18,
                                        ),
                                      ),
                              )
                            : (assetPath != null
                                ? Image.asset(
                                    assetPath,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Icon(
                                      fallbackIcon,
                                      color: isSelected
                                          ? Colors.white
                                          : scheme.onSurfaceVariant,
                                      size: 18,
                                    ),
                                  )),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : scheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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

