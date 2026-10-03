import 'package:flutter/material.dart';

/// CommercePal palette — "Ink + Maroon accent".
///
/// Maroon is reserved for brand moments and the primary call to action. Ink
/// carries text and UI chrome, amber-orange signals deals and savings. Prefer
/// [Theme.of] / [CommerceColors] in widgets so dark mode adapts automatically;
/// these constants are the raw light-mode values.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------
  static const Color maroon = Color(0xFF8A0A55);
  static const Color maroonDark = Color(0xFF6B0742);
  static const Color maroonLight = Color(0xFFB8327F);
  static const Color maroonSoft = Color(0xFFF9E8F1);

  // ---------------------------------------------------------------------------
  // Ink (text & UI chrome)
  // ---------------------------------------------------------------------------
  static const Color ink = Color(0xFF0F172A);
  static const Color ink2 = Color(0xFF334155);
  static const Color inkMuted = Color(0xFF5B6472);
  static const Color inkSubtle = Color(0xFF8A93A1);

  // ---------------------------------------------------------------------------
  // Commerce signals
  // ---------------------------------------------------------------------------
  static const Color deal = Color(0xFFE8590C);
  static const Color dealSoft = Color(0xFFFFEFE5);
  static const Color star = Color(0xFFF59F00);

  // ---------------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------------
  static const Color surface = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFFF4F5F7);
  static const Color surfaceMuted = Color(0xFFEEF0F3);
  static const Color border = Color(0xFFE3E6EA);
  static const Color borderStrong = Color(0xFFC9CED6);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF12805C);
  static const Color successSoft = Color(0xFFE6F4EE);
  static const Color warning = Color(0xFFB45309);
  static const Color warningSoft = Color(0xFFFEF3E2);
  static const Color error = Color(0xFFC62828);
  static const Color errorSoft = Color(0xFFFDECEC);
  static const Color info = Color(0xFF0B6BCB);
  static const Color infoSoft = Color(0xFFE7F1FB);

  // ---------------------------------------------------------------------------
  // Legacy aliases — kept so existing screens pick up the new palette. New
  // code should use the names above.
  // ---------------------------------------------------------------------------
  static const Color primary = maroon;

  /// Formerly the gold CTA colour; now the rating/star amber.
  static const Color secondary = star;

  /// Formerly a vibrant pink; links and selection now use the brand maroon.
  static const Color pink = maroon;

  /// Formerly the cream page background; now the neutral canvas.
  static const Color cream = canvas;
  static const Color lightGrey = surfaceMuted;
  static const Color navy = ink;
  static const Color onSecondary = ink;
}
