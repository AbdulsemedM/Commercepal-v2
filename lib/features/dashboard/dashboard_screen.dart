import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/widgets/pill_bottom_nav_bar.dart';
import 'package:commercepal/features/home/presentation/pages/home_page.dart';
import 'package:commercepal/features/categories/presentation/pages/categories_page.dart';
import 'package:commercepal/features/cart/presentation/screen/cart_page.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/profile/presentation/screen/profile_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const <Widget>[
    HomePage(),
    CategoriesPage(),
    CartPage(),
    ProfilePage(),
  ];

  void changeTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get or create CartBloc
    CartBloc cartBloc;
    try {
      cartBloc = context.read<CartBloc>();
    } catch (e) {
      cartBloc = CartBloc()..add(CartLoadRequested());
    }

    return BlocProvider.value(
      value: cartBloc,
      child: BlocBuilder<CartBloc, CartState>(
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
      ),
    );
  }
}
