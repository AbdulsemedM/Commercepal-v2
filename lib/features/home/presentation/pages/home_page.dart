import 'package:flutter/material.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import '../widgets/banner_section.dart';
import '../widgets/categories_section.dart';
import '../widgets/deal_of_day_section.dart';
import '../widgets/recently_viewed_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: Spacing.md),
            // Banner section
            const BannerSection(),
            const SizedBox(height: Spacing.xl),
            // Categories section
            const CategoriesSection(),
            const SizedBox(height: Spacing.xl),
            // Deal of the Day section
            const DealOfDaySection(),
            const SizedBox(height: Spacing.xl),
            // Recently Viewed section
            const RecentlyViewedSection(),
          ],
        ),
      ),
    );
  }
}
