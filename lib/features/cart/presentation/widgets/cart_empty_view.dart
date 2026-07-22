import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/services/localization_service.dart';

/// Colorful empty-cart illustration with a clear CTA (no motion).
class CartEmptyView extends StatelessWidget {
  const CartEmptyView({
    super.key,
    required this.onStartShopping,
    this.onBrowseCategories,
  });

  final VoidCallback onStartShopping;
  final VoidCallback? onBrowseCategories;

  @override
  Widget build(BuildContext context) {
    final String title = LocalizationService.t(context, 'cart.emptyTitle');
    final String subtitle =
        LocalizationService.t(context, 'cart.emptySubtitle');
    final String cta = LocalizationService.t(context, 'cart.startShopping');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: double.infinity,
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFFFFF4FA),
                AppColors.cream,
                Color(0xFFFFF8E8),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              const Positioned(
                top: -40,
                right: -30,
                child: _GlowOrb(
                  size: 180,
                  color: Color(0x55E9146B),
                ),
              ),
              const Positioned(
                top: 120,
                left: -50,
                child: _GlowOrb(
                  size: 140,
                  color: Color(0x55F5B301),
                ),
              ),
              const Positioned(
                bottom: 80,
                right: -20,
                child: _GlowOrb(
                  size: 120,
                  color: Color(0x4499045E),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xl,
                      vertical: Spacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const _CartHeroBadge(),
                        const SizedBox(height: Spacing.xl),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: AppColors.navy.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: Spacing.xl),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: onStartShopping,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.onSecondary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              cta,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        if (onBrowseCategories != null) ...[
                          const SizedBox(height: Spacing.sm),
                          TextButton(
                            onPressed: onBrowseCategories,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.pink,
                            ),
                            child: const Text(
                              'Browse categories',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartHeroBadge extends StatelessWidget {
  const _CartHeroBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFFF5CA8),
                  AppColors.primary,
                  Color(0xFF6B043F),
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
          ),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
          const Positioned(
            top: 18,
            right: 22,
            child: _Sparkle(color: AppColors.secondary, size: 22),
          ),
          const Positioned(
            bottom: 28,
            left: 18,
            child: _Sparkle(color: Colors.white, size: 16),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double arm = size.width / 2;

    final Path path = Path()
      ..moveTo(cx, cy - arm)
      ..quadraticBezierTo(cx, cy, cx + arm, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + arm)
      ..quadraticBezierTo(cx, cy, cx - arm, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - arm)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
