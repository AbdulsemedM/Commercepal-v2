import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Supplies English Material (and Cupertino) localizations for locales that
/// [GlobalMaterialLocalizations] does not support (e.g. Amharic, Somali),
/// so that TextField and other Material widgets do not throw
/// "No MaterialLocalizations found".
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  static const _unsupportedByMaterial = ['am', 'so'];

  @override
  bool isSupported(Locale locale) =>
      _unsupportedByMaterial.contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Supplies English Cupertino localizations for the same unsupported locales.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  static const _unsupported = ['am', 'so'];

  @override
  bool isSupported(Locale locale) =>
      _unsupported.contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

/// Supplies English Widgets localizations for the same unsupported locales.
class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  static const _unsupported = ['am', 'so'];

  @override
  bool isSupported(Locale locale) =>
      _unsupported.contains(locale.languageCode);

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}
