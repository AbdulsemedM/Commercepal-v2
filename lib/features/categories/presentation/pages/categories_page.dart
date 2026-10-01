import 'package:flutter/material.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/categories/bloc/categories_bloc.dart';
import 'package:commercepal/features/categories/data/models/category.dart';
// import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/product_grid.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  Category? _selectedCategory;

  void _navigateToTab(BuildContext context, int tabIndex) {
    final DashboardScreenState? dashboardState = context
        .findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.changeTab(tabIndex);
    }
  }


  @override
  Widget build(BuildContext context) {
    final int cartCount = context.watch<CartBloc>().itemCount;

    return BlocProvider(
      create: (context) => CategoriesBloc()..add(FetchCategories()),
      child: Scaffold(
        appBar: AppBarWidget(
          cartCount: cartCount,
          onSearchTap: () {
            context.push(AppRoutes.productSearch);
          },
          onSearchSubmitted: (String query) {
            context.push(
              '${AppRoutes.productSearch}?query=${Uri.encodeComponent(query)}',
            );
            return null;
          },
          onLogoTap: () {
            // Handle logo tap
          },
          onCartTap: () {
            _navigateToTab(context, 2);
          },
        ),
        body: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesError) {
              return AppEmptyState(
                isError: true,
                icon: Icons.category_outlined,
                title: context.tr('common.somethingWentWrong'),
                subtitle: state.message,
                primaryLabel: context.tr('common.retry'),
                onPrimary: () =>
                    context.read<CategoriesBloc>().add(FetchCategories()),
              );
            }

            if (state is CategoriesLoaded) {
              final categories = state.categories;
              if (categories.isEmpty) {
                return AppEmptyState(
                  icon: Icons.category_outlined,
                  title: context.tr('categories.empty'),
                );
              }

              // Set default selected category if not set
              if (_selectedCategory == null && categories.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _selectedCategory = categories.first;
                  });
                });
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CategorySidebar(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (Category category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                  if (_selectedCategory != null)
                    ProductGrid(
                      categoryName: _selectedCategory!.name,
                      subCategories: _selectedCategory!.subCategories,
                      isLoading: false,
                      errorMessage: null,
                    ),
                ],
              );
            }

            return const _CategoriesSkeleton();
          },
        ),
      ),
    );
  }
}

class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: CategorySidebar.width,
          color: scheme.surfaceContainerHigh,
          child: Column(
            children: List<Widget>.generate(
              7,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.sm),
                child: Column(
                  children: <Widget>[
                    ShimmerLoading(
                      width: 44,
                      height: 44,
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                    ),
                    SizedBox(height: 6),
                    ShimmerLoading(width: 56, height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(Spacing.sm),
            mainAxisSpacing: Spacing.sm,
            crossAxisSpacing: Spacing.xs,
            childAspectRatio: 0.72,
            physics: const NeverScrollableScrollPhysics(),
            children: List<Widget>.generate(
              9,
              (_) => const Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: ShimmerLoading(borderRadius: AppRadius.mdAll),
                  ),
                  SizedBox(height: 6),
                  ShimmerLoading(width: 60, height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
