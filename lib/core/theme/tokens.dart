import 'package:flutter/material.dart';

/// Corner radii. Commerce surfaces stay fairly tight (8–12) so dense product
/// grids read as a catalogue, not a collage.
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// Top-only radius for bottom sheets.
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

/// Durations and curves. Keep motion short and purposeful; long animations
/// make a shopping app feel slow.
class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve exit = Curves.easeInCubic;
}

/// Elevation as shadows. Light mode relies on borders + a hint of shadow;
/// dark mode relies on surface tone, so shadows are near-invisible there.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> sm(Brightness brightness) => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(
            alpha: brightness == Brightness.light ? 0.05 : 0.3,
          ),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> md(Brightness brightness) => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(
            alpha: brightness == Brightness.light ? 0.07 : 0.35,
          ),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(
            alpha: brightness == Brightness.light ? 0.03 : 0.2,
          ),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> lg(Brightness brightness) => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(
            alpha: brightness == Brightness.light ? 0.12 : 0.45,
          ),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
}

/// Minimum interactive sizes (Material/Apple HIG accessibility guidance).
class AppSizes {
  AppSizes._();

  static const double minTouchTarget = 48;
  static const double buttonLg = 52;
  static const double buttonMd = 44;
  static const double buttonSm = 36;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;

  /// Max content width on tablets / foldables so lines stay readable.
  static const double maxContentWidth = 720;
}
