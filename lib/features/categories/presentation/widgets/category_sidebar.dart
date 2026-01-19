import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/categories/data/models/category.dart';

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
      width: 120,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final Category category = categories[index];
          final bool isSelected = selectedCategory?.slug == category.slug;

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
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

