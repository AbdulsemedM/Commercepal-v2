import 'package:flutter/material.dart';

import 'package:commercepal/core/storage/storage.dart';

/// Controls ThemeMode and persists preference to secure storage.
class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.light})
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
        return ThemeMode.light;
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

/// Provides [ThemeController] below [MaterialApp] (e.g. for profile theme toggle).
class ThemeControllerScope extends InheritedWidget {
  const ThemeControllerScope({
    super.key,
    required this.themeController,
    required super.child,
  });

  final ThemeController themeController;

  static ThemeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope not found');
    return scope!.themeController;
  }

  @override
  bool updateShouldNotify(ThemeControllerScope oldWidget) =>
      themeController != oldWidget.themeController;
}
