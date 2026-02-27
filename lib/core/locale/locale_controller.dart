import 'package:flutter/material.dart';
import 'package:commercepal/core/storage/storage.dart';

class LocaleController extends ChangeNotifier {
  LocaleController() : _locale = const Locale('en') {
    _loadSaved();
  }

  Locale _locale;
  Locale get locale => _locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('am'),
    Locale('so'),
  ];

  Future<void> _loadSaved() async {
    final code = await Storage().getLocale();
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    await Storage().saveLocale(languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }
}

class LocaleControllerScope extends InheritedWidget {
  const LocaleControllerScope({
    super.key,
    required this.localeController,
    required super.child,
  });

  final LocaleController localeController;

  static LocaleController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<LocaleControllerScope>();
    assert(scope != null, 'LocaleControllerScope not found');
    return scope!.localeController;
  }

  @override
  bool updateShouldNotify(LocaleControllerScope oldWidget) =>
      localeController != oldWidget.localeController;
}
