import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/categories/bloc/categories_bloc.dart';
import 'package:commercepal/features/home/bloc/home_discover_bloc.dart';
import 'package:commercepal/features/home/bloc/recently_viewed_bloc.dart';
import 'package:commercepal/app/router/app_router.dart';
import '../widgets/category_quad_cards.dart';
import '../widgets/home_header.dart';
import '../widgets/home_discover_section.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/trust_badges_strip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateToTab(BuildContext context, int tabIndex) {
    final DashboardScreenState? dashboardState =
        context.findAncestorStateOfType<DashboardScreenState>();
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
        // Search bar + delivery line + quick links on one brand band.
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(
            AppBarWidget.barHeight + HomeHeaderExtras.height,
          ),
          child: Column(
            children: <Widget>[
              AppBarWidget(
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
                onCartTap: () {
                  _navigateToTab(context, 2);
                },
              ),
              const HomeHeaderExtras(),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => _onPullToRefresh(context),
          child: CustomScrollView(
            key: const PageStorageKey<String>('home_scroll_v1'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: Spacing.md),
                      child: CategoryQuadCards(),
                    ),
                    const SizedBox(height: Spacing.xl),
                    // "Keep shopping" — hidden until something was viewed.
                    const RecentlyViewedSection(),
                  ],
                ),
              ),
              const HomeDiscoverSection(),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: Spacing.xl,
                    bottom: Spacing.xl,
                  ),
                  child: TrustBadgesStrip(),
                ),
              ),
            ],
          ),
        ),
      );
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
                return homeScaffold(context, cartBloc!.itemCount);
              },
            )
          : Builder(
              builder: (BuildContext context) => homeScaffold(context, 0),
            ),
    );
  }
}
