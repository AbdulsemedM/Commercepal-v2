import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/update/app_update_check_result.dart';
import 'package:commercepal/core/update/app_update_check_service.dart';
import 'package:commercepal/core/update/app_update_modal.dart';
import 'package:commercepal/features/profile/data/repository/profile_repository.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/notification_service.dart';

/// Branded launch screen: logo tile, wordmark, tagline and a slim loader
/// while the update check runs (minimum ~3 s, unchanged).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color _deep = Color(0xFF4A0430);
  static const Color _onBrand = Colors.white;

  final Storage _storage = Storage();
  bool _hasNavigated = false;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  Animation<double> _interval(double begin, double end,
          [Curve c = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _intro, curve: Interval(begin, end, curve: c));

  late final Animation<double> _logoScale = Tween<double>(begin: 0.6, end: 1)
      .animate(_interval(0, 0.55, Curves.easeOutBack));
  late final Animation<double> _logoFade = _interval(0, 0.35);
  late final Animation<double> _wordFade = _interval(0.3, 0.7);
  late final Animation<Offset> _wordSlide = Tween<Offset>(
    begin: const Offset(0, 0.4),
    end: Offset.zero,
  ).animate(_interval(0.3, 0.7));
  late final Animation<double> _tagFade = _interval(0.45, 0.85);
  late final Animation<double> _footFade = _interval(0.6, 1);

  @override
  void initState() {
    super.initState();
    _runSplashAndVersionCheck();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect "reduce motion": show the final frame immediately.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _intro.value = 1;
    } else if (!_intro.isAnimating && _intro.value == 0) {
      _intro.forward();
    }
  }

  Future<void> _navigateAfterAuth() async {
    if (!mounted) return;
    try {
      await _storage.markAppOpened().timeout(const Duration(seconds: 5));
    } catch (_) {
      // Best-effort: proceed even if Keychain write is slow or unavailable.
    }
    if (mounted) context.go(AppRoutes.dashboard);
  }

  Future<void> _proceedToAppOnce() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    await _navigateAfterAuth();
    unawaited(_preloadProfileIfAuthenticated());
  }

  Future<void> _preloadProfileIfAuthenticated() async {
    try {
      final bool hasTokens = await _storage.hasTokens();
      if (!hasTokens) return;
      await Future.wait(<Future<void>>[
        ProfileRepository().refreshProfileCache(),
        NotificationService().registerTokenWithBackend(),
      ]);
    } catch (_) {
      // Best-effort: keep any existing cache and continue to the app.
    }
  }

  Future<AppUpdateCheckResult> _checkForUpdateWithTimeout() {
    return AppUpdateCheckService.check().timeout(
      const Duration(seconds: 8),
      onTimeout: () => const AppUpdateCheckResult(
        updateType: AppUpdateType.none,
        currentVersion: '',
        latestVersion: '',
        storeUrl: '',
      ),
    );
  }

  Future<void> _runSplashAndVersionCheck() async {
    const Duration minSplashDuration = Duration(seconds: 3);

    final List<dynamic> results = await Future.wait(<Future<dynamic>>[
      Future<void>.delayed(minSplashDuration),
      _checkForUpdateWithTimeout(),
    ]);

    final AppUpdateCheckResult result = results[1] as AppUpdateCheckResult;

    if (!mounted) return;

    if (result.hasUpdate) {
      await AppUpdateModal.show(
        context,
        result: result,
        onLater: () {
          unawaited(_proceedToAppOnce());
        },
      );
      if (!mounted) return;
      if (!result.isMandatory) {
        await _proceedToAppOnce();
      }
      return;
    }

    await _proceedToAppOnce();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _deep,
      ),
      child: Scaffold(
        backgroundColor: _deep,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[AppColors.maroon, _deep],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Two soft light shapes give depth without visual noise.
              const _Glow(alignment: Alignment(-1.2, -0.9), size: 420),
              const _Glow(alignment: Alignment(1.3, 0.7), size: 360),
              SafeArea(
                child: Column(
                  children: <Widget>[
                    const Spacer(flex: 5),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 44,
                                spreadRadius: -6,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Image(
                            image: AssetImage('assets/images/Icon.png'),
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                    FadeTransition(
                      opacity: _wordFade,
                      child: SlideTransition(
                        position: _wordSlide,
                        child: Semantics(
                          header: true,
                          label: 'CommercePal',
                          excludeSemantics: true,
                          child: Text.rich(
                            const TextSpan(
                              children: <InlineSpan>[
                                TextSpan(text: 'Commerce'),
                                TextSpan(
                                  text: 'Pal',
                                  style: TextStyle(color: AppColors.star),
                                ),
                              ],
                            ),
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: _onBrand,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    FadeTransition(
                      opacity: _tagFade,
                      child: Text(
                        context.tr('splash.tagline'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: _onBrand.withValues(alpha: 0.72),
                          letterSpacing: 4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(flex: 4),
                    FadeTransition(
                      opacity: _footFade,
                      child: Column(
                        children: <Widget>[
                          if (!reduceMotion)
                            SizedBox(
                              width: 140,
                              child: ClipRRect(
                                borderRadius: AppRadius.pillAll,
                                child: LinearProgressIndicator(
                                  minHeight: 3,
                                  color: _onBrand,
                                  backgroundColor:
                                      _onBrand.withValues(alpha: 0.18),
                                ),
                              ),
                            ),
                          const SizedBox(height: Spacing.sm),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              context.tr('splash.status'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _onBrand.withValues(alpha: 0.72),
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.verified_user_outlined,
                                size: 14,
                                color: _onBrand.withValues(alpha: 0.55),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.tr('splash.trust'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _onBrand.withValues(alpha: 0.55),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.lg),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.alignment, required this.size});

  final Alignment alignment;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
