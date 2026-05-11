import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/categories/bloc/categories_bloc.dart';
import 'package:commercepal/features/categories/data/models/category.dart';
// import 'package:commercepal/features/categories/data/models/sub_category.dart';
import 'package:commercepal/services/auth_service.dart';
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
    return BlocProvider(
      create: (context) => CategoriesBloc()..add(FetchCategories()),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBarWidget(
          cartCount: 2,
          userInitials: AuthService().userInitials ?? 'U',
          onSearchTap: () {
            // Navigate to search screen when search bar is tapped
            context.push(AppRoutes.productSearch);
          },
          onSearchSubmitted: (String query) {
            // Navigate to search screen with query
            context.push(
              '${AppRoutes.productSearch}?query=${Uri.encodeComponent(query)}',
            );
            return null;
          },
          onLogoTap: () {
            // Handle logo tap
          },
          onCartTap: () {
            // Navigate to cart tab
            _navigateToTab(context, 2);
          },
          onProfileTap: () {
            // Navigate to profile tab
            _navigateToTab(context, 3);
          },
          hasNotification: false,
        ),
        body: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoriesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CategoriesBloc>().add(FetchCategories());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is CategoriesLoaded) {
              final categories = state.categories;
              if (categories.isEmpty) {
                return const Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
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

            return const Center(
              child: Text(
                'Loading categories...',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}
