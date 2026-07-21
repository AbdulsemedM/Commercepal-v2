import 'package:flutter/material.dart';

import 'colors.dart';

/// Shared radii, shadows, and brand gradients for commerce surfaces.
class AppDecorations {
  AppDecorations._();

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double categoryChipSize = 56;

  static BorderRadius get cardBorderRadius =>
      BorderRadius.circular(radiusMd);

  static BorderRadius get chipBorderRadius =>
      BorderRadius.circular(radiusSm);

  /// Soft elevated card shadow (matches commercepal.com product cards).
  static List<BoxShadow> softCardShadow([Color? shadowColor]) {
    final Color c = shadowColor ?? Colors.black;
    return <BoxShadow>[
      BoxShadow(
        color: c.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: c.withValues(alpha: 0.04),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Maroon → gold hero gradient (website “Shop the World” banner).
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.primary,
      Color(0xFFB45309),
      AppColors.secondary,
    ],
    stops: <double>[0.0, 0.55, 1.0],
  );

  /// Semi-transparent overlay used on top of banner images.
  static LinearGradient get heroImageOverlay => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          AppColors.primary.withValues(alpha: 0.72),
          AppColors.secondary.withValues(alpha: 0.55),
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

  /// Soft cream used for quantity steppers / icon tiles on cream pages.
  static const Color softCream = Color(0xFFFDF3E3);

  /// Primary action gradient (magenta → deep maroon).
  static const LinearGradient primaryCtaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      AppColors.pink,
      AppColors.primary,
    ],
  );

  /// Cycled pastel gradients for category / subcategory tiles.
  static const List<LinearGradient> accentGradients = <LinearGradient>[
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFA78BFA), Color(0xFF7C3AED)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFF472B6), Color(0xFFDB2777)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFFBBF24), Color(0xFFD97706)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF2DD4BF), Color(0xFF0D9488)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF4ADE80), Color(0xFF16A34A)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF94A3B8), Color(0xFF475569)],
    ),
  ];

  static LinearGradient accentGradientAt(int index) =>
      accentGradients[index % accentGradients.length];
}
