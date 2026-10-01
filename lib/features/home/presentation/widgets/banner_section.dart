import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

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
    // Respect the OS "reduce motion" setting: no auto-advancing carousel.
    final bool reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduceMotion) return;
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

  void _onBannerTap(int index) {
    switch (index) {
      case 0:
        context.push(AppRoutes.megaSale);
        break;
      case 1:
        context.push(AppRoutes.salePromotion);
        break;
      case 2:
        _showComingSoonDialog();
        break;
    }
  }

  void _showComingSoonDialog() {
    AppDialog.show<void>(
      context,
      icon: const Icon(Icons.bolt_rounded),
      title: context.tr('home.flashDeals.comingSoonTitle'),
      message: context.tr('home.flashDeals.comingSoonMessage'),
      actions: <AppDialogAction>[
        AppDialogAction(label: context.tr('common.gotIt'), isPrimary: true),
      ],
    );
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>[
      context.tr('home.banner.megaSale'),
      context.tr('home.banner.newArrivals'),
      context.tr('home.banner.flashDeals'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: AspectRatio(
          aspectRatio: _bannerAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              NotificationListener<ScrollStartNotification>(
                // Pause auto-advance while the user is swiping.
                onNotification: (ScrollStartNotification n) {
                  if (n.dragDetails != null) _autoAdvanceTimer?.cancel();
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _bannerAssets.length,
                  itemBuilder: (BuildContext context, int index) {
                    final double screenWidth = MediaQuery.sizeOf(context).width;
                    final double dpr = MediaQuery.devicePixelRatioOf(context);
                    // Decode near display width, not full 1536px source.
                    final int cacheWidth =
                        ((screenWidth - (Spacing.gutter * 2)) * dpr).round();
                    return Semantics(
                      button: true,
                      label: labels[index],
                      hint: '${index + 1}/${_bannerAssets.length}',
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () => _onBannerTap(index),
                        child: Image.asset(
                          _bannerAssets[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          cacheWidth: cacheWidth > 0 ? cacheWidth : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: Spacing.xs,
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        List<Widget>.generate(_bannerAssets.length, (int i) {
                      final bool active = i == _currentPage;
                      return AnimatedContainer(
                        duration: AppMotion.fast,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.pillAll,
                          color: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
