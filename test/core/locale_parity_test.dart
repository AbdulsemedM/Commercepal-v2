import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every locale must define exactly the keys English defines, and keep the
/// same `{placeholders}`, so no screen falls back to raw keys or English.
void main() {
  const List<String> locales = <String>['am', 'ar', 'so'];
  final RegExp placeholder = RegExp(r'\{(\w+)\}');

  Map<String, String> load(String code) {
    final String raw = File('assets/locales/$code.json').readAsStringSync();
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  final Map<String, String> en = load('en');

  for (final String code in locales) {
    test('$code.json matches en.json keys and placeholders', () {
      final Map<String, String> other = load(code);
      final Set<String> missing =
          en.keys.toSet().difference(other.keys.toSet());
      final Set<String> extra = other.keys.toSet().difference(en.keys.toSet());
      expect(missing, isEmpty, reason: 'Missing in $code: $missing');
      expect(extra, isEmpty, reason: 'Not in en: $extra');

      final List<String> mismatched = <String>[
        for (final MapEntry<String, String> e in en.entries)
          if (other.containsKey(e.key) &&
              !_sameSet(
                placeholder.allMatches(e.value).map((m) => m[1]!),
                placeholder.allMatches(other[e.key]!).map((m) => m[1]!),
              ))
            e.key,
      ];
      expect(mismatched, isEmpty, reason: 'Placeholder drift in $code');
    });
  }
}

bool _sameSet(Iterable<String> a, Iterable<String> b) =>
    a.toSet().length == b.toSet().length && a.toSet().containsAll(b.toSet());
