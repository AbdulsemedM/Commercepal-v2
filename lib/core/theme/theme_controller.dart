import 'package:flutter/material.dart';

import 'package:commercepal/core/storage/storage.dart';

/// Controls ThemeMode and persists preference to secure storage.
class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.system})
    : _mode = initialMode;

  ThemeMode _mode;
  ThemeMode get themeMode => _mode;

  static ThemeMode parseThemeMode(String raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> loadPersistedTheme() async {
    final raw = await Storage().getThemeMode();
    _mode = parseThemeMode(raw);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await Storage().saveThemeMode(serializeThemeMode(mode));
    notifyListeners();
  }
}
