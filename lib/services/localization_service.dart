import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LocalizationService {
  static const List<String> _supportedLocales = ['en', 'ar', 'am', 'so'];

  static Map<String, Map<String, String>> _loaded = {};
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    final bundle = rootBundle;
    for (final code in _supportedLocales) {
      try {
        // Decode directly: loadString() hands >50 KB assets to an isolate,
        // which is slower at startup and never completes in widget tests.
        final ByteData bytes = await bundle.load('assets/locales/$code.json');
        final String json = utf8.decode(bytes.buffer.asUint8List(
          bytes.offsetInBytes,
          bytes.lengthInBytes,
        ));
        final map = Map<String, String>.from(
          (jsonDecode(json) as Map).map(
            (k, v) => MapEntry(k as String, v as String),
          ),
        );
        _loaded[code] = map;
      } catch (_) {
        _loaded[code] = {};
      }
    }
    _initialized = true;
  }

  static String _localeCode(BuildContext context) {
    final String code =
        Localizations.localeOf(context).languageCode.toLowerCase();
    return _loaded.containsKey(code) ? code : 'en';
  }

  static String t(BuildContext context, String key) {
    final String locale = _localeCode(context);
    return _loaded[locale]?[key] ?? _loaded['en']?[key] ?? key;
  }

  /// Resolved string without a [BuildContext] (e.g. background interceptors). Call
  /// [ensureInitialized] first.
  static String tForLanguage(String languageCode, String key) {
    final String code = languageCode.toLowerCase();
    final String resolved =
        _supportedLocales.contains(code) ? code : 'en';
    return _loaded[resolved]?[key] ?? _loaded['en']?[key] ?? key;
  }

  static List<String> get supportedLocaleCodes => List.unmodifiable(_supportedLocales);

  /// [t] with `{placeholder}` substitution, e.g.
  /// `tf(context, 'price.percentOff', {'percent': '20'})`.
  static String tf(
    BuildContext context,
    String key,
    Map<String, Object?> args,
  ) {
    String out = t(context, key);
    args.forEach((String k, Object? v) {
      out = out.replaceAll('{$k}', '${v ?? ''}');
    });
    return out;
  }
}

extension LocalizationX on BuildContext {
  /// Translated string for [key], with optional `{placeholder}` [args].
  String tr(String key, [Map<String, Object?>? args]) => args == null
      ? LocalizationService.t(this, key)
      : LocalizationService.tf(this, key, args);
}
