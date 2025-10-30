import 'package:flutter/material.dart';

/// Controls ThemeMode and persists preference when storage is available.
class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.system})
    : _mode = initialMode;

  ThemeMode _mode;
  ThemeMode get themeMode => _mode;

  void setThemeMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    // TODO: persist to storage when implemented
    notifyListeners();
  }
}
