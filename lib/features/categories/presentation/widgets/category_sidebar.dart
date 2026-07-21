import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
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
    return Container(
      width: 118,
      color: Theme.of(context).scaffoldBackgroundColor,
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
          final gradient = AppDecorations.accentGradientAt(index);

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            child: InkWell(
              onTap: () => onCategorySelected(category),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: (hasNetworkImage || assetPath != null)
                            ? null
                            : (isSelected
                                ? const LinearGradient(
                                    colors: <Color>[
                                      AppColors.pink,
                                      AppColors.primary,
                                    ],
                                  )
                                : gradient),
                        color: (hasNetworkImage || assetPath != null)
                            ? Colors.white
                            : null,
                      ),
                      child: ClipOval(
                        child: hasNetworkImage
                            ? Image.network(
                                category.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => assetPath != null
                                    ? Image.asset(assetPath, fit: BoxFit.cover)
                                    : _iconFallback(fallbackIcon),
                              )
                            : (assetPath != null
                                ? Image.asset(
                                    assetPath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _iconFallback(fallbackIcon),
                                  )
                                : _iconFallback(fallbackIcon)),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? Colors.white : AppColors.navy,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
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

  Widget _iconFallback(IconData icon) {
    return Center(
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
