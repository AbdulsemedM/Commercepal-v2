import 'package:flutter/material.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';

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
      body: Column(
        children: <Widget>[
          
          const Expanded(child: Center(child: Text('Home'))),
        ],
      ),
    );
  }
}
