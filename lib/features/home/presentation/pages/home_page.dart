import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/categories/bloc/categories_bloc.dart';
import 'package:commercepal/features/home/bloc/home_catalog_mode_cubit.dart';
import 'package:commercepal/features/home/bloc/home_discover_bloc.dart';
import 'package:commercepal/features/home/bloc/home_wholesale_bloc.dart';
import 'package:commercepal/features/home/bloc/recently_viewed_bloc.dart';
import 'package:commercepal/app/router/app_router.dart';
import '../widgets/banner_section.dart';
import '../widgets/categories_section.dart';
import '../widgets/home_catalog_mode_toggle.dart';
import '../widgets/home_discover_section.dart';
import '../widgets/home_wholesale_section.dart';
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
    final mode = context.read<HomeCatalogModeCubit>().state;
    if (mode == HomeCatalogMode.wholesale) {
      context.read<HomeWholesaleBloc>().add(FetchHomeWholesale());
    } else {
      context.read<HomeDiscoverBloc>().add(FetchHomeDiscover());
    }
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
      return BlocListener<HomeCatalogModeCubit, HomeCatalogMode>(
        listenWhen: (previous, current) =>
            current == HomeCatalogMode.wholesale &&
            previous != HomeCatalogMode.wholesale,
        listener: (context, mode) {
          context.read<HomeWholesaleBloc>().add(FetchHomeWholesale());
        },
        child: Scaffold(
          appBar: AppBarWidget(
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
            onLogoTap: () {
              // Handle logo tap
            },
            onCartTap: () {
              _navigateToTab(context, 2);
            },
          ),
          body: RefreshIndicator(
            onRefresh: () => _onPullToRefresh(context),
            child: CustomScrollView(
              key: const PageStorageKey<String>('home_scroll_v1'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                const SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: Spacing.md),
                      BannerSection(),
                      SizedBox(height: Spacing.md),
                      HomeCatalogModeToggle(),
                      SizedBox(height: Spacing.lg),
                      CategoriesSection(),
                      SizedBox(height: Spacing.lg),
                      // Hidden until the shopper has viewed something.
                      RecentlyViewedSection(),
                    ],
                  ),
                ),
                BlocBuilder<HomeCatalogModeCubit, HomeCatalogMode>(
                  builder: (context, mode) {
                    if (mode == HomeCatalogMode.wholesale) {
                      return const HomeWholesaleSection();
                    }
                    return const HomeDiscoverSection();
                  },
                ),
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
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoriesBloc>(
          create: (_) => CategoriesBloc()..add(FetchCategories()),
        ),
        BlocProvider<HomeCatalogModeCubit>(
          create: (_) => HomeCatalogModeCubit(),
        ),
        BlocProvider<HomeDiscoverBloc>(
          create: (_) => HomeDiscoverBloc()..add(FetchHomeDiscover()),
        ),
        BlocProvider<HomeWholesaleBloc>(
          create: (_) => HomeWholesaleBloc(),
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
