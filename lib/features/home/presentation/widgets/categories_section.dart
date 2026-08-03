import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/categories/bloc/categories_bloc.dart';
import 'package:commercepal/features/categories/data/models/category.dart';
import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/core/utils/category_image_assets.dart';
import 'package:commercepal/core/widgets/app_network_image.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/home/presentation/widgets/home_section_header.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  Category? _selectedCategory;
  int _selectedIndex = 0; // 0 = "All"

  static IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('cosmetic') || name.contains('beauty')) {
      return Icons.face_outlined;
    } else if (name.contains('fashion') || name.contains('cloth')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('comput') || name.contains('electronic')) {
      return Icons.laptop_mac_outlined;
    } else if (name.contains('sport') || name.contains('fitness')) {
      return Icons.sports_soccer_outlined;
    } else if (name.contains('furniture') || name.contains('home')) {
      return Icons.chair_outlined;
    } else if (name.contains('food') || name.contains('grocery')) {
      return Icons.restaurant_outlined;
    } else if (name.contains('book') || name.contains('education')) {
      return Icons.menu_book_outlined;
    } else if (name.contains('toy') || name.contains('game')) {
      return Icons.toys_outlined;
    } else if (name.contains('health') || name.contains('medical')) {
      return Icons.medical_services_outlined;
    } else if (name.contains('auto') || name.contains('vehicle')) {
      return Icons.directions_car_outlined;
    } else if (name.contains('pet')) {
      return Icons.pets_outlined;
    } else if (name.contains('jewelry') || name.contains('watch')) {
      return Icons.watch_outlined;
    } else if (name.contains('phone') || name.contains('mobile') ||
        name.contains('technolog')) {
      return Icons.smartphone_outlined;
    } else if (name.contains('garden')) {
      return Icons.yard_outlined;
    }
    return Icons.category_outlined;
  }

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: HomeSectionHeader(
            title: LocalizationService.t(context, 'home.categories.title'),
            actionLabel: LocalizationService.t(context, 'home.categories.seeAll'),
            onAction: () {
              context
                  .findAncestorStateOfType<DashboardScreenState>()
                  ?.changeTab(1);
            },
          ),
        ),
        const SizedBox(height: Spacing.md),
        BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return _buildLoadingShimmer(context);
            }

            if (state is CategoriesError) {
              return _buildError(context, state.message);
            }

            if (state is CategoriesLoaded) {
              return _buildCategoriesList(context, state.categories);
            }

            return _buildLoadingShimmer(context);
          },
        ),
      ],
    );
  }

  Widget _buildSubcategoriesView(BuildContext context, Category category) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
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
                onPressed: () => setState(() {
                  _selectedCategory = null;
                  _selectedIndex = 0;
                }),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (subCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.lg,
            ),
            child: Text(
              'No subcategories',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          )
        else
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              itemCount: subCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.md),
              itemBuilder: (BuildContext context, int index) {
                final subCategory = subCategories[index];
                return SizedBox(
                  width: 72,
                  child: _SubCategoryBubbleTile(
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

  Widget _buildLoadingShimmer(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.md),
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: 72,
            child: Shimmer.fromColors(
              baseColor: scheme.surfaceContainerHighest,
              highlightColor: scheme.surface.withOpacity(0.85),
              child: Column(
                children: [
                  Container(
                    width: AppDecorations.categoryChipSize,
                    height: AppDecorations.categoryChipSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
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
    // Index 0 = "All" chip; categories start at index 1
    final int itemCount = categories.length + 1;

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.md),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return SizedBox(
              width: 72,
              child: _AllCategoryChip(
                selected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
            );
          }
          final category = categories[index - 1];
          final bool selected = _selectedIndex == index;
          return SizedBox(
            width: 72,
            child: _CategoryBubbleTile(
              category: category,
              index: index - 1,
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                  _selectedCategory = category;
                });
              },
              getIcon: _getCategoryIcon,
              getColor: _getCategoryColor,
            ),
          );
        },
      ),
    );
  }
}

class _AllCategoryChip extends StatelessWidget {
  const _AllCategoryChip({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: <Widget>[
          Container(
            width: AppDecorations.categoryChipSize,
            height: AppDecorations.categoryChipSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.pink : Colors.white,
              border: selected
                  ? null
                  : Border.all(color: const Color(0xFFF0E6D8)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: selected
                      ? AppColors.pink.withOpacity(0.3)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: selected ? Colors.white : AppColors.navy,
              size: 24,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'All',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.navy
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategoryBubbleTile extends StatelessWidget {
  const _CategoryBubbleTile({
    required this.category,
    required this.index,
    required this.selected,
    required this.onTap,
    required this.getIcon,
    required this.getColor,
  });

  final Category category;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final IconData Function(String name) getIcon;
  final Color Function(int index) getColor;

  @override
  Widget build(BuildContext context) {
    final icon = getIcon(category.name);
    final bool hasNetworkImage =
        category.imageUrl != null && category.imageUrl!.isNotEmpty;
    final String? assetPath =
        CategoryImageAssets.assetPathForName(category.name);
    final bool hasImage = hasNetworkImage || assetPath != null;

    final Widget iconFallback = Container(
      color: selected ? AppColors.pink : Colors.white,
      child: Icon(
        icon,
        color: selected ? Colors.white : AppColors.navy,
        size: 24,
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: <Widget>[
          Container(
            width: AppDecorations.categoryChipSize,
            height: AppDecorations.categoryChipSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (selected && !hasImage) ? AppColors.pink : Colors.white,
              border: selected
                  ? Border.all(color: AppColors.pink, width: 2.5)
                  : Border.all(color: const Color(0xFFF0E6D8)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: selected
                      ? AppColors.pink.withOpacity(0.3)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: hasNetworkImage
                  ? AppNetworkImage(
                      url: category.imageUrl!,
                      fit: BoxFit.cover,
                      width: AppDecorations.categoryChipSize,
                      height: AppDecorations.categoryChipSize,
                      memCacheWidth: (AppDecorations.categoryChipSize *
                              MediaQuery.devicePixelRatioOf(context))
                          .round(),
                      memCacheHeight: (AppDecorations.categoryChipSize *
                              MediaQuery.devicePixelRatioOf(context))
                          .round(),
                      errorWidget: assetPath != null
                          ? Image.asset(assetPath, fit: BoxFit.cover)
                          : iconFallback,
                    )
                  : (assetPath != null
                      ? Image.asset(
                          assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => iconFallback,
                        )
                      : iconFallback),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            category.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.navy
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SubCategoryBubbleTile extends StatelessWidget {
  const _SubCategoryBubbleTile({
    required this.subCategory,
    required this.icon,
    required this.color,
  });

  final SubCategory subCategory;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Keep spaces/punctuation in the display name; encode for the route only.
        final query = Uri.encodeComponent(subCategory.name.trim());
        context.push('${AppRoutes.productSearch}?query=$query');
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: <Widget>[
          Container(
            width: AppDecorations.categoryChipSize,
            height: AppDecorations.categoryChipSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.08),
            ),
            child: ClipOval(child: _buildImage(context)),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            subCategory.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: AppColors.navy,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final bool hasNetworkImage =
        subCategory.imageUrl != null && subCategory.imageUrl!.isNotEmpty;
    final String? path =
        CategoryImageAssets.assetPathForName(subCategory.name);
    final int memCache = (AppDecorations.categoryChipSize *
            MediaQuery.devicePixelRatioOf(context))
        .round();

    Widget networkImage() {
      return AppNetworkImage(
        url: subCategory.imageUrl!,
        fit: BoxFit.cover,
        width: AppDecorations.categoryChipSize,
        height: AppDecorations.categoryChipSize,
        memCacheWidth: memCache,
        memCacheHeight: memCache,
        errorWidget: _buildPlaceholder(),
      );
    }

    // Nested folder assets: assets/images/subcategories/{parent}/{slug}.jpg
    if (path != null &&
        path.contains('/subcategories/') &&
        path.split('/subcategories/').last.contains('/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            hasNetworkImage ? networkImage() : _buildPlaceholder(),
      );
    }
    if (hasNetworkImage) {
      return networkImage();
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: color.withOpacity(0.12),
      child: Center(
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
