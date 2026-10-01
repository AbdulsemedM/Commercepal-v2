import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every literal key passed to `context.tr(...)` / `LocalizationService.t(...)`
/// must exist in en.json; otherwise users see the raw key on screen.
void main() {
  test('all literal translation keys used in lib/ exist in en.json', () {
    final Map<String, dynamic> en = jsonDecode(
      File('assets/locales/en.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final RegExp usage = RegExp(
      r"""(?:\.tr\(|LocalizationService\.tf?\(\s*\w+,\s*)\s*'([a-zA-Z][\w.]*)'""",
    );
    final Map<String, List<String>> missing = <String, List<String>>{};

    for (final FileSystemEntity f
        in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final String src = f.readAsStringSync();
      for (final RegExpMatch m in usage.allMatches(src)) {
        final String key = m.group(1)!;
        // Keys built with interpolation are checked where they're defined.
        if (key.endsWith('.')) continue;
        if (!en.containsKey(key)) {
          (missing[key] ??= <String>[]).add(f.path);
        }
      }
    }

    expect(missing, isEmpty, reason: 'Missing keys: $missing');
  });
}
