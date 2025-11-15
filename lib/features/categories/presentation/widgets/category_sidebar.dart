import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class CategorySidebar extends StatelessWidget {
  const CategorySidebar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const List<String> categories = <String>[
    'categories.technology',
    'categories.realEstate',
    'categories.watch',
    'categories.homeLife',
    'categories.cosmeticSurgery',
    'categories.fashion',
    'categories.homeAppliances',
    'categories.jewelry',
    'categories.babyProducts',
    'categories.sporting',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final String categoryKey = categories[index];
          final String categoryName =
              LocalizationService.t(context, categoryKey);
          final bool isSelected = selectedCategory == categoryKey;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            child: InkWell(
              onTap: () => onCategorySelected(categoryKey),
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
                  categoryName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

