import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/widgets/pill_bottom_nav_bar.dart';
import 'package:commercepal/features/home/presentation/pages/home_page.dart';
import 'package:commercepal/features/categories/presentation/pages/categories_page.dart';
import 'package:commercepal/features/cart/presentation/screen/cart_page.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/profile/presentation/screen/profile_page.dart';
import 'package:commercepal/features/onboarding/dashboard_coach_overlay.dart';
import 'package:commercepal/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.initialTab});

  final int? initialTab;

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;

  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const CategoriesPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab ?? 0;
    if (_currentIndex < 0 || _currentIndex >= _pages.length) {
      _currentIndex = 0;
    }
    AuthService().addListener(_onAuthServiceChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initQuickActions();
      if (mounted) {
        maybeShowDashboardCoachOverlay(context);
      }
    });
  }

  Future<void> _initQuickActions() async {
    try {
      const QuickActions quickActions = QuickActions();
      await quickActions.initialize((String shortcutType) {
        switch (shortcutType) {
          case 'action_search':
            appRouter.push(AppRoutes.productSearch);
            break;
          case 'action_cart':
            changeTab(2);
            break;
          case 'action_orders':
            appRouter.push(AppRoutes.orderHistory);
            break;
        }
      });
      await quickActions.setShortcutItems(<ShortcutItem>[
        const ShortcutItem(
          type: 'action_search',
          localizedTitle: 'Search products',
        ),
        const ShortcutItem(
          type: 'action_cart',
          localizedTitle: 'Cart',
        ),
        const ShortcutItem(
          type: 'action_orders',
          localizedTitle: 'Orders',
        ),
      ]);
    } catch (_) {}
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

          final ColorScheme scheme = Theme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: scheme.surface,
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
