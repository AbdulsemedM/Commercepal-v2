import 'package:flutter/material.dart';

import 'colors.dart';
import 'tokens.dart';

/// Shared radii, shadows, and brand gradients for commerce surfaces.
///
/// Kept for existing call sites; new code should use [AppRadius],
/// [AppShadows] and [CommerceColors] directly.
class AppDecorations {
  AppDecorations._();

  static const double radiusSm = AppRadius.sm;
  static const double radiusMd = AppRadius.md;
  static const double radiusLg = AppRadius.lg;
  static const double categoryChipSize = 56;

  static BorderRadius get cardBorderRadius => AppRadius.mdAll;

  static BorderRadius get chipBorderRadius => AppRadius.smAll;

  /// Subtle card elevation.
  static List<BoxShadow> softCardShadow([Color? shadowColor]) {
    final Color c = shadowColor ?? Colors.black;
    return <BoxShadow>[
      BoxShadow(
        color: c.withValues(alpha: 0.06),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
      BoxShadow(
        color: c.withValues(alpha: 0.03),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Deep maroon brand gradient for hero moments (splash, promo banners).
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.maroon, AppColors.maroonDark],
  );

  /// Overlay used on top of banner images to keep text legible.
  static LinearGradient get heroImageOverlay => LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: <Color>[
          Colors.black.withValues(alpha: 0.55),
          Colors.black.withValues(alpha: 0.0),
        ],
      );

  static BoxDecoration elevatedCard({
    required Color background,
    Color? shadowColor,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: cardBorderRadius,
      boxShadow: softCardShadow(shadowColor),
    );
  }

  /// Neutral tile fill for quantity steppers / icon tiles.
  static const Color softCream = AppColors.surfaceMuted;

  /// Primary action fill. Kept as a gradient type for existing call sites,
  /// but solid: the new system uses flat colour for CTAs.
  static const LinearGradient primaryCtaGradient = LinearGradient(
    colors: <Color>[AppColors.maroon, AppColors.maroon],
  );

  /// Muted mid-tone fills for image fallbacks on category / cart tiles.
  /// Call sites draw white icons on top, so every pair keeps white legible.
  static const List<LinearGradient> accentGradients = <LinearGradient>[
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFA23B72), Color(0xFF7E1E57)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF4F6D8F), Color(0xFF3A5576)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFC2643A), Color(0xFF9E4A26)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF2F7F73), Color(0xFF1F6258)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF6E5A9E), Color(0xFF54437F)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF64748B), Color(0xFF475569)],
    ),
  ];

  static LinearGradient accentGradientAt(int index) =>
      accentGradients[index % accentGradients.length];
}
