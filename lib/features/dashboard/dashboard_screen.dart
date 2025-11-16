import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/widgets/pill_bottom_nav_bar.dart';
import 'package:commercepal/features/home/presentation/pages/home_page.dart';
import 'package:commercepal/features/categories/presentation/pages/categories_page.dart';
import 'package:commercepal/features/cart/presentation/screen/cart_page.dart';
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
  final List<int> _badges = <int>[0, 0, 2, 0];

  void changeTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: PillBottomNavBar(
        // activeColor: Theme.of(context).colorScheme.primary,
        currentIndex: _currentIndex,
        badgeCounts: _badges,
        onTap: (int i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
