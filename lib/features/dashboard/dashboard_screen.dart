import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/widgets/pill_bottom_nav_bar.dart';
import 'package:commercepal/features/home/presentation/pages/home_page.dart';
import 'package:commercepal/features/categories/presentation/pages/categories_page.dart';
import 'package:commercepal/features/cart/presentation/screen/cart_page.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/profile/presentation/screen/profile_page.dart';
import 'package:commercepal/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.initialTab});

  final int? initialTab;

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const <Widget>[
    HomePage(),
    CategoriesPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab ?? 0;
    if (_currentIndex < 0 || _currentIndex >= _pages.length) {
      _currentIndex = 0;
    }
    AuthService().addListener(_onAuthServiceChanged);
  }

  @override
  void dispose() {
    AuthService().removeListener(_onAuthServiceChanged);
    super.dispose();
  }

  void _onAuthServiceChanged() {
    if (!mounted) return;
    if (AuthService().sessionExpired) {
      AuthService().clearSessionExpired();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your session has expired.'),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              context.go(AppRoutes.login);
            },
          ),
        ),
      );
    }
  }

  void changeTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the CartBloc provided at the app level
    return BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          // Calculate badge counts
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

          final List<int> badges = <int>[0, 0, cartCount, 0];

          return Scaffold(
            backgroundColor: AppColors.lightGrey,
            body: IndexedStack(index: _currentIndex, children: _pages),
            bottomNavigationBar: PillBottomNavBar(
              // activeColor: Theme.of(context).colorScheme.primary,
              currentIndex: _currentIndex,
              badgeCounts: badges,
              onTap: (int i) => setState(() => _currentIndex = i),
            ),
          );
        },
    );
  }
}
