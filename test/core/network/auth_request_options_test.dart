import 'package:commercepal/core/network/auth_request_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldAttachGuestSessionId', () {
    test('guest requests always include session id', () {
      expect(
        shouldAttachGuestSessionId(
          hasAccessToken: false,
          includeGuestSession: false,
        ),
        isTrue,
      );
    });

    test('authenticated cart requests omit session id', () {
      expect(
        shouldAttachGuestSessionId(
          hasAccessToken: true,
          includeGuestSession: false,
        ),
        isFalse,
      );
    });

    test('authenticated merge requests include session id', () {
      expect(
        shouldAttachGuestSessionId(
          hasAccessToken: true,
          includeGuestSession: true,
        ),
        isTrue,
      );
    });

    test('forced guest session always includes session id', () {
      expect(
        shouldAttachGuestSessionId(
          hasAccessToken: true,
          includeGuestSession: false,
          forceGuestSession: true,
        ),
        isTrue,
      );
    });
  });
}
