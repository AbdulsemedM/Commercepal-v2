import 'package:flutter/material.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/product_grid.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String _selectedCategory = 'categories.technology';

  void _navigateToTab(BuildContext context, int tabIndex) {
    final DashboardScreenState? dashboardState = context
        .findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.changeTab(tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBarWidget(
        cartCount: 2,
        userInitials: 'AW',
        onSearchSubmitted: (String query) {
          // Handle search submission
          debugPrint('Search query: $query');
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
        hasNotification: true,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CategorySidebar(
            selectedCategory: _selectedCategory,
            onCategorySelected: (String category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          ProductGrid(categoryKey: _selectedCategory),
        ],
      ),
    );
  }
}



