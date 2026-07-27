import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/update/app_update_check_result.dart';
import 'package:commercepal/core/update/app_update_check_service.dart';
import 'package:commercepal/core/update/app_update_modal.dart';
import 'package:commercepal/features/profile/data/repository/profile_repository.dart';
import 'package:commercepal/services/notification_service.dart';

/// Splash matching the Commercepal maroon/gold intro mockup.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _primaryDeep = Color(0xFF5C0339);
  static const Color _plum = Color(0xFF430227);
  static const Color _textOnDark = Color(0xFFFFF6E9);
  static const Color _textMuted = Color(0x9EFFF6E9); // ~62%

  final Storage _storage = Storage();

  late final AnimationController _introController;
  late final AnimationController _haloController;
  late final AnimationController _dotsController;
  late final AnimationController _twinkleController;

  late final Animation<double> _iconOpacity;
  late final Animation<double> _iconScale;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _statusOpacity;
  late final Animation<Offset> _statusSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _introController.forward();
    _haloController.repeat(reverse: true);
    _dotsController.repeat();
    _twinkleController.repeat(reverse: true);
    _runSplashAndVersionCheck();
  }

  void _setupAnimations() {
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    // Icon: 0 → 700ms
    _iconOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _iconScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    // Wordmark: ~850ms
    _wordmarkOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.42, 0.70, curve: Curves.easeOut),
    );
    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.42, 0.70, curve: Curves.easeOut),
      ),
    );

    // Tagline: ~1200ms
    _taglineOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.60, 0.85, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.40),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.60, 0.85, curve: Curves.easeOut),
      ),
    );

    // Status: ~1500ms
    _statusOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );
    _statusSlide = Tween<Offset>(
      begin: const Offset(0, 0.40),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  Future<void> _navigateAfterAuth() async {
    if (!mounted) return;
    await _storage.markAppOpened();
    if (mounted) context.go(AppRoutes.dashboard);
  }

  Future<void> _proceedToApp() async {
    await _navigateAfterAuth();
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

  Future<void> _runSplashAndVersionCheck() async {
    const Duration minSplashDuration = Duration(seconds: 3);

    final results = await Future.wait(<Future<dynamic>>[
      Future<void>.delayed(minSplashDuration),
      AppUpdateCheckService.check(),
      _preloadProfileIfAuthenticated(),
    ]);

    final AppUpdateCheckResult result = results[1] as AppUpdateCheckResult;

    if (!mounted) return;

    if (result.hasUpdate) {
      await AppUpdateModal.show(
        context,
        result: result,
        onLater: () {
          if (mounted) {
            _proceedToApp();
          }
        },
      );
      return;
    }

    await _proceedToApp();
  }

  @override
  void dispose() {
    _introController.dispose();
    _haloController.dispose();
    _dotsController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.6, -1.0),
            end: Alignment(0.4, 1.0),
            colors: <Color>[
              AppColors.primary,
              _primaryDeep,
              _plum,
            ],
            stops: <double>[0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AnimatedBuilder(
              animation: _twinkleController,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  painter: _WorldMapDotsPainter(
                    progress: _twinkleController.value,
                  ),
                );
              },
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        AnimatedBuilder(
                          animation: _haloController,
                          builder: (BuildContext context, Widget? child) {
                            final double t = _haloController.value;
                            final double scale = 0.92 + (t * 0.16);
                            final double opacity = 0.75 + (t * 0.25);
                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: <Color>[
                                  AppColors.secondary.withValues(alpha: 0.35),
                                  AppColors.pink.withValues(alpha: 0.18),
                                  Colors.transparent,
                                ],
                                stops: const <double>[0.0, 0.55, 0.75],
                              ),
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _iconOpacity,
                          child: ScaleTransition(
                            scale: _iconScale,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Image(
                                image: AssetImage(
                                  'assets/images/removebg.png',
                                ),
                                width: 104,
                                height: 104,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _wordmarkOpacity,
                    child: SlideTransition(
                      position: _wordmarkSlide,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Image(
                            image: AssetImage('assets/images/removebg.png'),
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Text.rich(
                            TextSpan(
                              children: <InlineSpan>[
                                TextSpan(
                                  text: 'Commerce',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                TextSpan(
                                  text: 'pal',
                                  style: TextStyle(
                                    color: _textOnDark,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: const Text(
                        'SHOP THE WORLD',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: FadeTransition(
                opacity: _statusOpacity,
                child: SlideTransition(
                  position: _statusSlide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: _dotsController,
                        builder: (BuildContext context, Widget? child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(3, (int i) {
                              // Stagger each dot so they bounce in sequence.
                              final double wave =
                                  (_dotsController.value - (i * 0.2) + 1.0) %
                                      1.0;
                              final double bounce = _loadingDotWave(wave);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Transform.translate(
                                  offset: Offset(0, -10 * bounce),
                                  child: Transform.scale(
                                    scale: 0.65 + (0.45 * bounce),
                                    child: Opacity(
                                      opacity: 0.45 + (0.55 * bounce),
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: <Color>[
                                              AppColors.secondary,
                                              AppColors.pink,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Finding great deals…',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Smooth ease-in-out bump used for sequential loading-dot bounce.
  double _loadingDotWave(double t) {
    // Active pulse in the first ~45% of the cycle, then rest.
    if (t >= 0.45) return 0;
    final double x = t / 0.45;
    return math.sin(x * math.pi);
  }
}

class _WorldMapDotsPainter extends CustomPainter {
  _WorldMapDotsPainter({required this.progress});

  final double progress;

  static const List<(double, double, double)> _dots =
      <(double, double, double)>[
    (40, 120, 2.2),
    (70, 150, 1.6),
    (30, 180, 1.8),
    (330, 100, 2.0),
    (300, 140, 1.6),
    (340, 180, 1.8),
    (60, 540, 2.0),
    (90, 580, 1.6),
    (320, 560, 2.0),
    (290, 600, 1.8),
    (200, 70, 1.6),
    (180, 610, 1.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double opacity = 0.10 + (0.20 * (0.5 - (progress - 0.5).abs()) * 2);
    final Paint paint = Paint()
      ..color = const Color(0xFFFFF6E9).withValues(alpha: opacity);

    const double designW = 375;
    const double designH = 660;
    final double sx = size.width / designW;
    final double sy = size.height / designH;

    for (int i = 0; i < _dots.length; i++) {
      final (double cx, double cy, double r) = _dots[i];
      // Slight per-dot phase so they don't all pulse in lockstep.
      final double phase = math.sin((progress * math.pi * 2) + (i * 0.7));
      final double localOpacity =
          (0.10 + (0.20 * ((phase + 1) / 2))).clamp(0.08, 0.32);
      paint.color = const Color(0xFFFFF6E9).withValues(alpha: localOpacity);
      canvas.drawCircle(
        Offset(cx * sx, cy * sy),
        r * ((sx + sy) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WorldMapDotsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
