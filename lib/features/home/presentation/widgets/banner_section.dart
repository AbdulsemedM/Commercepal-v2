import 'dart:async';

import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    String promo = '';
    try {
      promo = AppUpdateRemoteConfig.homePromoBanner;
    } catch (_) {}

    Widget placeholder() {
      return Container(
        color: scheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.image,
            color: scheme.onSurfaceVariant,
            size: 60,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
      height: 180,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
                  errorBuilder:
                      (BuildContext context, Object error, StackTrace? stackTrace) {
                    return placeholder();
                  },
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (promo.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      color: Colors.black54,
                      child: Text(
                        promo,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: promo.isNotEmpty ? Spacing.xs : 0,
                      bottom: Spacing.sm,
                    ),
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
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
