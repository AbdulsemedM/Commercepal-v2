import 'package:commercepal/core/update/remote_config_value_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteConfigValueValidators.isAllowedStoreUrl', () {
    test('allows Play Store HTTPS URLs on Android', () {
      expect(
        RemoteConfigValueValidators.isAllowedStoreUrl(
          'https://play.google.com/store/apps/details?id=com.commercepal.commercepal',
          android: true,
        ),
        isTrue,
      );
    });

    test('allows market://details intents on Android', () {
      expect(
        RemoteConfigValueValidators.isAllowedStoreUrl(
          'market://details?id=com.commercepal.commercepal',
          android: true,
        ),
        isTrue,
      );
    });

    test('allows App Store HTTPS URLs on iOS', () {
      expect(
        RemoteConfigValueValidators.isAllowedStoreUrl(
          'https://apps.apple.com/app/id123456789',
          android: false,
        ),
        isTrue,
      );
      expect(
        RemoteConfigValueValidators.isAllowedStoreUrl(
          'https://itunes.apple.com/app/id123456789',
          android: false,
        ),
        isTrue,
      );
    });

    test('rejects phishing and wrong-scheme URLs', () {
      expect(
        RemoteConfigValueValidators.isAllowedStoreUrl(
          'https://evil.com/fake-store',
          android: true,
        ),
        isFalse,
      );
      expect(
        RemoteConfigValueValidators.isAllowedStoreUrl(
          'http://play.google.com/store/apps/details?id=x',
          android: true,
        ),
        isFalse,
      );
      expect(
        RemoteConfigValueValidators.isAllowedStoreUrl(
          'https://play.google.com/store/apps/details?id=x',
          android: false,
        ),
        isFalse,
      );
      expect(
        RemoteConfigValueValidators.isAllowedStoreUrl(
          'javascript:alert(1)',
          android: true,
        ),
        isFalse,
      );
      expect(
        RemoteConfigValueValidators.isAllowedStoreUrl('', android: true),
        isFalse,
      );
    });
  });

  group('RemoteConfigValueValidators.isValidAppVersion', () {
    test('accepts major.minor.patch and build suffixes', () {
      expect(RemoteConfigValueValidators.isValidAppVersion('1.2.3'), isTrue);
      expect(RemoteConfigValueValidators.isValidAppVersion('6.1.1+157'), isTrue);
      expect(RemoteConfigValueValidators.isValidAppVersion(' 4.0.0 '), isTrue);
    });

    test('rejects malformed versions', () {
      expect(RemoteConfigValueValidators.isValidAppVersion('1.2'), isFalse);
      expect(RemoteConfigValueValidators.isValidAppVersion('abc'), isFalse);
      expect(RemoteConfigValueValidators.isValidAppVersion(''), isFalse);
    });
  });

  group('RemoteConfigValueValidators.sanitizeDisplayMessage', () {
    test('strips HTML-like tags and control characters', () {
      expect(
        RemoteConfigValueValidators.sanitizeDisplayMessage(
          'Hello <b>world</b>\x00!',
        ),
        'Hello world!',
      );
    });

    test('collapses whitespace and truncates', () {
      expect(
        RemoteConfigValueValidators.sanitizeDisplayMessage(
          '  too   many   spaces  ',
        ),
        'too many spaces',
      );
      final long = 'a' * 250;
      final sanitized =
          RemoteConfigValueValidators.sanitizeDisplayMessage(long);
      expect(sanitized.length, 200);
    });
  });
}
