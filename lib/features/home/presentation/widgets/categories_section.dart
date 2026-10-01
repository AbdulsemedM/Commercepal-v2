import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/utils/category_image_assets.dart';
import 'package:commercepal/features/categories/bloc/categories_bloc.dart';
import 'package:commercepal/features/categories/data/models/category.dart';
import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/features/home/presentation/widgets/home_section_header.dart';
import 'package:commercepal/services/localization_service.dart';

const double _kTileWidth = 76;
const double _kRowHeight = 112;
const double _kBubble = AppDecorations.categoryChipSize;

/// Horizontal category bubbles; tapping one drills into its subcategories.
class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  Category? _selectedCategory;

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
    } else if (name.contains('phone') ||
        name.contains('mobile') ||
        name.contains('technolog')) {
      return Icons.smartphone_outlined;
    } else if (name.contains('garden')) {
      return Icons.yard_outlined;
    }
    return Icons.category_outlined;
  }

  void _select(Category? category) {
    HapticFeedback.selectionClick();
    setState(() => _selectedCategory = category);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      child: _selectedCategory != null
          ? KeyedSubtree(
              key: ValueKey<String>(_selectedCategory!.slug),
              child: _buildSubcategoriesView(context, _selectedCategory!),
            )
          : KeyedSubtree(
              key: const ValueKey<String>('all'),
              child: _buildRoot(context),
            ),
    );
  }

  Widget _buildRoot(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
          child: HomeSectionHeader(
            title: context.tr('home.categories.title'),
            actionLabel: context.tr('home.categories.seeAll'),
            onAction: () {
              context
                  .findAncestorStateOfType<DashboardScreenState>()
                  ?.changeTab(1);
            },
          ),
        ),
        const SizedBox(height: Spacing.sm),
        BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesError) {
              return AppEmptyState(
                compact: true,
                isError: true,
                icon: Icons.category_outlined,
                title: context.tr('common.somethingWentWrong'),
                primaryLabel: context.tr('common.retry'),
                onPrimary: () =>
                    context.read<CategoriesBloc>().add(FetchCategories()),
              );
            }
            if (state is CategoriesLoaded) {
              return _buildCategoriesList(context, state.categories);
            }
            return _buildLoading();
          },
        ),
      ],
    );
  }

  Widget _buildSubcategoriesView(BuildContext context, Category category) {
    final ThemeData theme = Theme.of(context);
    final List<SubCategory> subCategories = category.subCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: Spacing.xxs,
            end: Spacing.gutter,
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const BackButtonIcon(),
                onPressed: () => _select(null),
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs),
        if (subCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.gutter,
              vertical: Spacing.lg,
            ),
            child: Text(
              context.tr('home.categories.noSubcategories'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          SizedBox(
            height: _kRowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
              itemCount: subCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
              itemBuilder: (BuildContext context, int index) {
                final SubCategory sub = subCategories[index];
                return _BubbleTile(
                  label: sub.name,
                  image: _SubCategoryImage(
                    subCategory: sub,
                    icon: _getCategoryIcon(sub.name),
                  ),
                  onTap: () {
                    // Keep spaces/punctuation in the name; encode for route.
                    final String query = Uri.encodeComponent(sub.name.trim());
                    context.push('${AppRoutes.productSearch}?query=$query');
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: _kRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
        itemBuilder: (_, __) => const SizedBox(
          width: _kTileWidth,
          child: Column(
            children: <Widget>[
              ShimmerLoading(
                width: _kBubble,
                height: _kBubble,
                borderRadius: BorderRadius.all(Radius.circular(_kBubble)),
              ),
              SizedBox(height: Spacing.xs),
              ShimmerLoading(width: 52, height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, List<Category> categories) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: _kRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _BubbleTile(
              label: context.tr('home.categories.all'),
              selected: true,
              image: ColoredBox(
                color: scheme.primaryContainer,
                child: Icon(
                  Icons.grid_view_rounded,
                  color: scheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              onTap: () => context
                  .findAncestorStateOfType<DashboardScreenState>()
                  ?.changeTab(1),
            );
          }
          final Category category = categories[index - 1];
          return _BubbleTile(
            label: category.name,
            image: _CategoryImage(
              category: category,
              icon: _getCategoryIcon(category.name),
            ),
            onTap: () => _select(category),
          );
        },
      ),
    );
  }
}

/// Circular image + up to two lines of label.
class _BubbleTile extends StatelessWidget {
  const _BubbleTile({
    required this.label,
    required this.image,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final Widget image;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return SizedBox(
      width: _kTileWidth,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              children: <Widget>[
                Container(
                  width: _kBubble,
                  height: _kBubble,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surface,
                    border: Border.all(
                      color:
                          selected ? scheme.primary : context.commerce.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: ClipOval(child: image),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: scheme.onSurface,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _iconFallback(BuildContext context, IconData icon) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  return ColoredBox(
    color: scheme.surfaceContainerHigh,
    child: Icon(icon, color: scheme.onSurfaceVariant, size: 24),
  );
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.category, required this.icon});

  final Category category;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool hasNetworkImage =
        category.imageUrl != null && category.imageUrl!.isNotEmpty;
    final String? assetPath =
        CategoryImageAssets.assetPathForName(category.name);
    final Widget fallback = _iconFallback(context, icon);
    final int memCache =
        (_kBubble * MediaQuery.devicePixelRatioOf(context)).round();

    if (hasNetworkImage) {
      return AppNetworkImage(
        url: category.imageUrl!,
        fit: BoxFit.cover,
        width: _kBubble,
        height: _kBubble,
        memCacheWidth: memCache,
        memCacheHeight: memCache,
        errorWidget: assetPath != null
            ? Image.asset(assetPath, fit: BoxFit.cover)
            : fallback,
      );
    }
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return fallback;
  }
}

class _SubCategoryImage extends StatelessWidget {
  const _SubCategoryImage({required this.subCategory, required this.icon});

  final SubCategory subCategory;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool hasNetworkImage =
        subCategory.imageUrl != null && subCategory.imageUrl!.isNotEmpty;
    final String? path = CategoryImageAssets.assetPathForName(subCategory.name);
    final int memCache =
        (_kBubble * MediaQuery.devicePixelRatioOf(context)).round();
    final Widget fallback = _iconFallback(context, icon);

    Widget networkImage() {
      return AppNetworkImage(
        url: subCategory.imageUrl!,
        fit: BoxFit.cover,
        width: _kBubble,
        height: _kBubble,
        memCacheWidth: memCache,
        memCacheHeight: memCache,
        errorWidget: fallback,
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
            hasNetworkImage ? networkImage() : fallback,
      );
    }
    if (hasNetworkImage) return networkImage();
    return fallback;
  }
}
