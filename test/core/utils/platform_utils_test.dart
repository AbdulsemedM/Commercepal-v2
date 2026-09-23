import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformUtils.getAuthChannel', () {
    test('matches device login channel', () {
      expect(PlatformUtils.getAuthChannel(), PlatformUtils.getChannel());
    });
  });
}
