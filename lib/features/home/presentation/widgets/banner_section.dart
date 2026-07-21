import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';

/// Auto-advancing carousel of branded promo banners (matches the web).
class BannerSection extends StatefulWidget {
  const BannerSection({super.key});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  static const List<String> _bannerAssets = <String>[
    'assets/images/banner_mega_sale.png',
    'assets/images/banner_new_arrivals.png',
    'assets/images/banner_flashdeals.png',
  ];

  /// Matches the generated banner assets (1536x1024, 3:2) so nothing crops.
  static const double _bannerAspectRatio = 3 / 2;

  static const Duration _autoAdvanceInterval = Duration(seconds: 5);

  late final PageController _pageController;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scheduleAutoAdvance();
  }

  void _scheduleAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(_autoAdvanceInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final int next = (_currentPage + 1) % _bannerAssets.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _scheduleAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: _bannerAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _bannerAssets.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => context.push(AppRoutes.productSearch),
                  child: Image.asset(
                    _bannerAssets[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: Spacing.sm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(_bannerAssets.length, (int i) {
                  final bool active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: active
                          ? AppColors.secondary
                          : Colors.white.withValues(alpha: 0.55),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
