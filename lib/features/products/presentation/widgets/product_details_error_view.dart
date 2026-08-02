import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';

/// Decorative full-screen product detail error state.
class ProductDetailsErrorView extends StatelessWidget {
  const ProductDetailsErrorView({
    super.key,
    required this.message,
    this.errorCode,
    required this.onRetry,
    this.onGoBack,
  });

  final String message;
  final String? errorCode;
  final VoidCallback onRetry;
  final VoidCallback? onGoBack;

  bool get _isTemporarilyUnavailable =>
      errorCode == 'PRODUCT_TEMPORARILY_UNAVAILABLE' || errorCode == '503';

  bool get _isNotFound => errorCode == '404' || errorCode == 'PRODUCT_NOT_FOUND';

  bool get _isOffline =>
      message.toLowerCase().contains('internet') ||
      message.toLowerCase().contains('connection');

  _ErrorVisuals get _visuals {
    if (_isTemporarilyUnavailable) {
      return const _ErrorVisuals(
        icon: Icons.schedule_rounded,
        accent: AppColors.warning,
        title: 'Pricing temporarily unavailable',
        hint: 'We’re refreshing prices for this item. Please try again in a moment.',
      );
    }
    if (_isNotFound) {
      return const _ErrorVisuals(
        icon: Icons.search_off_rounded,
        accent: AppColors.pink,
        title: 'Product not found',
        hint: 'This item may have been removed or is no longer listed.',
      );
    }
    if (_isOffline) {
      return const _ErrorVisuals(
        icon: Icons.wifi_off_rounded,
        accent: AppColors.info,
        title: 'Connection issue',
        hint: 'Check your network and try again.',
      );
    }
    return const _ErrorVisuals(
      icon: Icons.error_outline_rounded,
      accent: AppColors.error,
      title: 'Unable to load product',
      hint: 'Something went wrong while loading this product.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ErrorVisuals visuals = _visuals;
    final String subtitle = message.trim().isNotEmpty ? message.trim() : visuals.hint;

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
              Positioned(
                top: -36,
                right: -28,
                child: _GlowOrb(
                  size: 170,
                  color: visuals.accent.withValues(alpha: 0.28),
                ),
              ),
              Positioned(
                top: 140,
                left: -48,
                child: _GlowOrb(
                  size: 130,
                  color: AppColors.secondary.withValues(alpha: 0.28),
                ),
              ),
              Positioned(
                bottom: 90,
                right: -18,
                child: _GlowOrb(
                  size: 120,
                  color: AppColors.primary.withValues(alpha: 0.22),
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
                        _ErrorHeroBadge(
                          icon: visuals.icon,
                          accent: visuals.accent,
                        ),
                        const SizedBox(height: Spacing.xl),
                        Text(
                          visuals.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
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
                            color: AppColors.navy.withValues(alpha: 0.68),
                          ),
                        ),
                        if (_isTemporarilyUnavailable) ...[
                          const SizedBox(height: Spacing.md),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.warning.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: AppColors.warning.withValues(alpha: 0.95),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Temporary service issue',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy.withValues(alpha: 0.78),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: Spacing.xl),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: onRetry,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.onSecondary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text(
                              'Try again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        if (onGoBack != null) ...[
                          const SizedBox(height: Spacing.sm),
                          TextButton(
                            onPressed: onGoBack,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.navy.withValues(alpha: 0.7),
                            ),
                            child: const Text(
                              'Go back',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
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

class _ErrorVisuals {
  const _ErrorVisuals({
    required this.icon,
    required this.accent,
    required this.title,
    required this.hint,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String hint;
}

class _ErrorHeroBadge extends StatelessWidget {
  const _ErrorHeroBadge({
    required this.icon,
    required this.accent,
  });

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            accent.withValues(alpha: 0.22),
            accent.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accent.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: accent.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            icon,
            size: 34,
            color: accent,
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

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
            colors: <Color>[
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
