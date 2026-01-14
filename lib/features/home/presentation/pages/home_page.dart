import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/services/auth_service.dart';
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
    // Try to get CartBloc from context (provided at dashboard level)
    CartBloc? cartBloc;
    try {
      cartBloc = context.read<CartBloc>();
    } catch (e) {
      // CartBloc not available, will use default count of 0
    }

    return BlocBuilder<CartBloc, CartState>(
      bloc: cartBloc,
      builder: (context, cartState) {
        int cartCount = 0;
        if (cartState is CartLoaded ||
            cartState is CartItemAdded ||
            cartState is CartItemUpdated ||
            cartState is CartItemDeleted) {
          final cart = cartState is CartLoaded
              ? cartState.cart
              : cartState is CartItemAdded
              ? cartState.cart
              : cartState is CartItemUpdated
              ? cartState.cart
              : (cartState as CartItemDeleted).cart;
          cartCount = cart.totalItems;
        }

        return Scaffold(
          appBar: AppBarWidget(
            cartCount: cartCount,
            userInitials: AuthService().userInitials ?? 'U',
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
      },
    );
  }
}
