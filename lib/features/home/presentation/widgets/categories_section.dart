import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/categories/bloc/categories_bloc.dart';
import 'package:commercepal/features/categories/data/models/category.dart';
import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  Category? _selectedCategory;

  // Icon mapping for categories
  static IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('cosmetic') || name.contains('beauty')) {
      return Icons.face;
    } else if (name.contains('fashion') || name.contains('cloth')) {
      return Icons.checkroom;
    } else if (name.contains('comput') || name.contains('electronic')) {
      return Icons.laptop;
    } else if (name.contains('sport') || name.contains('fitness')) {
      return Icons.sports_soccer;
    } else if (name.contains('furniture') || name.contains('home')) {
      return Icons.chair;
    } else if (name.contains('food') || name.contains('grocery')) {
      return Icons.restaurant;
    } else if (name.contains('book') || name.contains('education')) {
      return Icons.book;
    } else if (name.contains('toy') || name.contains('game')) {
      return Icons.toys;
    } else if (name.contains('health') || name.contains('medical')) {
      return Icons.local_hospital;
    } else if (name.contains('auto') || name.contains('vehicle')) {
      return Icons.directions_car;
    } else if (name.contains('pet')) {
      return Icons.pets;
    } else if (name.contains('jewelry') || name.contains('watch')) {
      return Icons.watch;
    } else if (name.contains('phone') || name.contains('mobile')) {
      return Icons.phone_android;
    } else if (name.contains('garden')) {
      return Icons.yard;
    }
    return Icons.category;
  }

  // Color mapping for categories
  static Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFFFF6B9D),
      Color(0xFF9B59B6),
      Color(0xFF3498DB),
      Color(0xFF2ECC71),
      Color(0xFFE67E22),
      Color(0xFFE74C3C),
      Color(0xFF1ABC9C),
      Color(0xFFF39C12),
      Color(0xFF34495E),
      Color(0xFF16A085),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory != null) {
      return _buildSubcategoriesView(context, _selectedCategory!);
    }

    return BlocProvider(
      create: (context) => CategoriesBloc()..add(FetchCategories()),
      child: Column(
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
                    context.findAncestorStateOfType<DashboardScreenState>()?.changeTab(1);
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
          BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return _buildLoadingShimmer();
              }

              if (state is CategoriesError) {
                return _buildError(context, state.message);
              }

              if (state is CategoriesLoaded) {
                return _buildCategoriesList(context, state.categories);
              }

              return _buildLoadingShimmer();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesView(BuildContext context, Category category) {
    final subCategories = category.subCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _selectedCategory = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (subCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.lg),
            child: Text(
              'No subcategories',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          )
        else
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              itemCount: subCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final subCategory = subCategories[index];
                return SizedBox(
                  width: 140,
                  child: _SubCategoryTile(
                    subCategory: subCategory,
                    icon: _getCategoryIcon(subCategory.name),
                    color: _getCategoryColor(index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: Spacing.sm,
          mainAxisSpacing: Spacing.sm,
          childAspectRatio: 0.85,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: Spacing.sm,
          mainAxisSpacing: Spacing.sm,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final Category category = categories[index];
          final hasImage = category.imageUrl != null && category.imageUrl!.isNotEmpty;
          final icon = _getCategoryIcon(category.name);
          final color = _getCategoryColor(index);

          return InkWell(
            onTap: () {
              setState(() => _selectedCategory = category);
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasImage
                        ? Image.network(
                            category.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildIconPlaceholder(icon, color),
                          )
                        : _buildIconPlaceholder(icon, color),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconPlaceholder(IconData icon, Color color) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Icon(icon, color: color, size: 40),
      ),
    );
  }
}

class _SubCategoryTile extends StatelessWidget {
  const _SubCategoryTile({
    required this.subCategory,
    required this.icon,
    required this.color,
  });

  final SubCategory subCategory;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hasImage = subCategory.imageUrl != null && subCategory.imageUrl!.isNotEmpty;
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: hasImage
                    ? Image.network(
                        subCategory.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: Spacing.sm),
              child: Text(
                subCategory.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
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

  Widget _buildPlaceholder() {
    return Container(
      color: color.withOpacity(0.12),
      child: Center(
        child: Icon(icon, color: color, size: 36),
      ),
    );
  }
}

