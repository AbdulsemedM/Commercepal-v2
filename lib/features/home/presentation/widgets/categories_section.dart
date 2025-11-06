import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  static const List<CategoryItem> categories = <CategoryItem>[
    CategoryItem(
      name: 'Cosmetics',
      icon: Icons.face,
      color: Color(0xFFFF6B9D),
    ),
    CategoryItem(
      name: 'Fashion',
      icon: Icons.checkroom,
      color: Color(0xFF9B59B6),
    ),
    CategoryItem(
      name: 'Computing',
      icon: Icons.laptop,
      color: Color(0xFF3498DB),
    ),
    CategoryItem(
      name: 'Sports',
      icon: Icons.sports_soccer,
      color: Color(0xFF2ECC71),
    ),
    CategoryItem(
      name: 'Furniture',
      icon: Icons.chair,
      color: Color(0xFFE67E22),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                LocalizationService.t(context, 'home.categories.title'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
              InkWell(
                onTap: () {
                  // TODO: Navigate to all categories
                },
                child: Text(
                  LocalizationService.t(context, 'home.categories.seeAll'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        // Horizontal scrollable categories
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              final CategoryItem category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: Spacing.md),
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to category
                  },
                  child: Column(
                    children: <Widget>[
                      // Circular icon container
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      // Category name
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

