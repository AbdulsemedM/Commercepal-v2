import 'dart:async';

import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/update/app_update_remote_config.dart';

class BannerSection extends StatefulWidget {
  const BannerSection({super.key});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  static const List<String> _bannerAssets = <String>[
    'assets/images/banner.png',
    'assets/images/banner1.jpeg',
    'assets/images/banner2.jpeg',
  ];

  static const Duration _autoAdvanceInterval = Duration(seconds: 4);

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
        duration: const Duration(milliseconds: 400),
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
    String promo = '';
    try {
      promo = AppUpdateRemoteConfig.homePromoBanner;
    } catch (_) {}

    Widget placeholder() {
      return Container(
        decoration: const BoxDecoration(gradient: AppDecorations.heroGradient),
        child: const Center(
          child: Text(
            'Shop the World',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: AppDecorations.cardBorderRadius,
        boxShadow: AppDecorations.softCardShadow(),
      ),
      child: ClipRRect(
        borderRadius: AppDecorations.cardBorderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _bannerAssets.length,
              itemBuilder: (BuildContext context, int index) {
                return Image.asset(
                  _bannerAssets[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) {
                    return placeholder();
                  },
                );
              },
            ),
            // Maroon → gold overlay for website-like hero presence
            DecoratedBox(
              decoration: BoxDecoration(gradient: AppDecorations.heroImageOverlay),
            ),
            // Headline
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Shop the World',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        letterSpacing: 0.4,
                        shadows: <Shadow>[
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    if (promo.isNotEmpty) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        promo,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
                          : Colors.white.withValues(alpha: 0.45),
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
