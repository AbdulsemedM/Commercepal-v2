import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme workSans(Color baseColor) {
    final TextTheme base = GoogleFonts.workSansTextTheme();
    return base.apply(bodyColor: baseColor, displayColor: baseColor);
  }
}
