import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/widgets/app_snackbar.dart';
import 'package:commercepal/core/widgets/pill_bottom_nav_bar.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/home/presentation/pages/home_page.dart';
import 'package:commercepal/features/categories/presentation/pages/categories_page.dart';
import 'package:commercepal/features/cart/presentation/screen/cart_page.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/profile/presentation/screen/profile_page.dart';
import 'package:commercepal/features/onboarding/dashboard_coach_overlay.dart';
import 'package:commercepal/features/support_chat/presentation/widgets/draggable_support_chat_fab.dart';
import 'package:commercepal/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.initialTab});

  final int? initialTab;

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  static const int _tabCount = 4;

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab ?? 0;
    if (_currentIndex < 0 || _currentIndex >= _tabCount) {
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
    // Read localized titles before any await (context use).
    final (String, String, String) titles = (
      context.tr('quickActions.search'),
      context.tr('nav.cart'),
      context.tr('quickActions.orders'),
    );
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
        ShortcutItem(
          type: 'action_search',
          localizedTitle: titles.$1,
        ),
        ShortcutItem(
          type: 'action_cart',
          localizedTitle: titles.$2,
        ),
        ShortcutItem(
          type: 'action_orders',
          localizedTitle: titles.$3,
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
      AppSnackbars.info(
        context,
        context.tr('session.expired'),
        actionLabel: context.tr('auth.login.loginButton'),
        onAction: () => context.go(AppRoutes.login),
      );
    }
  }

  void changeTab(int index) {
    if (index >= 0 && index < _tabCount) {
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
          final int cartCount = context.read<CartBloc>().itemCount;

          final List<int> badges = <int>[0, 0, cartCount, 0];

          final ColorScheme scheme = Theme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: scheme.surface,
            body: Stack(
              children: <Widget>[
                IndexedStack(
                  index: _currentIndex,
                  children: <Widget>[
                    const HomePage(),
                    const CategoriesPage(),
                    const CartPage(),
                    ProfilePage(isActive: _currentIndex == 3),
                  ],
                ),
                const DraggableSupportChatFab(),
              ],
            ),
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
