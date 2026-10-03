import 'package:flutter/material.dart';

/// Type system: Inter for Latin/Somali, Noto Sans Arabic and Noto Sans
/// Ethiopic for the other scripts. All three are bundled (see pubspec
/// `fonts:`), so text renders instantly and offline.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = <String>[
    'NotoSansArabic',
    'NotoSansEthiopic',
  ];

  /// Tabular figures keep prices and counters from jittering as they change.
  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextStyle _style(
    double size,
    FontWeight weight,
    double height, {
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// Dense, commerce-oriented scale (body 14). Line heights are generous
  /// enough for Ethiopic and Arabic glyphs, which sit taller than Latin.
  static TextTheme textTheme(Color color) {
    final TextTheme base = TextTheme(
      displayLarge: _style(40, FontWeight.w700, 1.15, letterSpacing: -0.8),
      displayMedium: _style(34, FontWeight.w700, 1.18, letterSpacing: -0.6),
      displaySmall: _style(28, FontWeight.w700, 1.2, letterSpacing: -0.4),
      headlineLarge: _style(26, FontWeight.w700, 1.25, letterSpacing: -0.3),
      headlineMedium: _style(22, FontWeight.w700, 1.27, letterSpacing: -0.2),
      headlineSmall: _style(20, FontWeight.w700, 1.3, letterSpacing: -0.1),
      titleLarge: _style(18, FontWeight.w700, 1.33),
      titleMedium: _style(16, FontWeight.w600, 1.4),
      titleSmall: _style(14, FontWeight.w600, 1.43),
      bodyLarge: _style(16, FontWeight.w400, 1.5),
      bodyMedium: _style(14, FontWeight.w400, 1.45),
      bodySmall: _style(12.5, FontWeight.w400, 1.4),
      labelLarge: _style(14, FontWeight.w600, 1.3, letterSpacing: 0.1),
      labelMedium: _style(12, FontWeight.w600, 1.3, letterSpacing: 0.1),
      labelSmall: _style(11, FontWeight.w600, 1.3, letterSpacing: 0.2),
    );
    return base.apply(bodyColor: color, displayColor: color);
  }
}
