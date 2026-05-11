import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/cart/data/models/cart.dart';
import 'package:commercepal/features/categories/bloc/categories_bloc.dart';
import 'package:commercepal/features/home/bloc/home_discover_bloc.dart';
import 'package:commercepal/features/home/bloc/recently_viewed_bloc.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import '../widgets/banner_section.dart';
import '../widgets/categories_section.dart';
import '../widgets/deal_of_day_section.dart';
import '../widgets/home_discover_section.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/local_recent_product_views_strip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<LocalRecentProductViewsStripState> _localRecentKey =
      GlobalKey<LocalRecentProductViewsStripState>();

  void _navigateToTab(BuildContext context, int tabIndex) {
    final DashboardScreenState? dashboardState = context
        .findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.changeTab(tabIndex);
    }
  }

  Future<void> _onPullToRefresh(BuildContext context) async {
    context.read<CategoriesBloc>().add(FetchCategories());
    context.read<HomeDiscoverBloc>().add(FetchHomeDiscover());
    context.read<RecentlyViewedBloc>().add(FetchRecentlyViewed());
    try {
      context.read<CartBloc>().add(CartLoadRequested());
    } catch (_) {
      // CartBloc may be absent outside dashboard
    }
    await _localRecentKey.currentState?.reload();
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    CartBloc? cartBloc;
    try {
      cartBloc = context.read<CartBloc>();
    } catch (_) {
      // CartBloc not available, will use default count of 0
    }

    Widget homeScaffold(BuildContext context, int cartCount) {
      return Scaffold(
        appBar: AppBarWidget(
          cartCount: cartCount,
          userInitials: AuthService().userInitials ?? 'U',
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
          onProfileTap: () {
            _navigateToTab(context, 3);
          },
          hasNotification: false,
        ),
        body: RefreshIndicator(
          onRefresh: () => _onPullToRefresh(context),
          child: SingleChildScrollView(
            key: const PageStorageKey<String>('home_scroll_v1'),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: Spacing.md),
                const BannerSection(),
                const SizedBox(height: Spacing.lg),
                const CategoriesSection(),
                const SizedBox(height: Spacing.lg),
                const DealOfDaySection(),
                const SizedBox(height: Spacing.lg),
                const HomeDiscoverSection(),
                const SizedBox(height: Spacing.lg),
                LocalRecentProductViewsStrip(key: _localRecentKey),
                const RecentlyViewedSection(),
              ],
            ),
          ),
        ),
      );
    }

    int cartCountFromState(CartState cartState) {
      if (cartState is CartLoaded ||
          cartState is CartItemAdded ||
          cartState is CartItemUpdated ||
          cartState is CartItemDeleted) {
        final Cart cart = cartState is CartLoaded
            ? cartState.cart
            : cartState is CartItemAdded
                ? cartState.cart
                : cartState is CartItemUpdated
                    ? cartState.cart
                    : (cartState as CartItemDeleted).cart;
        return cart.totalItems;
      }
      return 0;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoriesBloc>(
          create: (_) => CategoriesBloc()..add(FetchCategories()),
        ),
        BlocProvider<HomeDiscoverBloc>(
          create: (_) => HomeDiscoverBloc()..add(FetchHomeDiscover()),
        ),
        BlocProvider<RecentlyViewedBloc>(
          create: (_) => RecentlyViewedBloc()..add(FetchRecentlyViewed()),
        ),
      ],
      child: cartBloc != null
          ? BlocBuilder<CartBloc, CartState>(
              bloc: cartBloc,
              builder: (BuildContext context, CartState cartState) {
                return homeScaffold(context, cartCountFromState(cartState));
              },
            )
          : Builder(
              builder: (BuildContext context) =>
                  homeScaffold(context, 0),
            ),
    );
  }
}
