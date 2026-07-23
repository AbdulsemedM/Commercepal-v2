import 'package:commercepal/features/checkout/presentation/utils/payment_phone_utils.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('parseProfilePhoneForField', () {
    test('parses Ethiopian international number', () {
      final parsed = parseProfilePhoneForField('251946514836');

      expect(parsed.initialCountryCode, 'ET');
      expect(parsed.localNumber, '946514836');
      expect(parsed.completeNumber, '251946514836');
    });
  });

  group('normalizePaymentAccount', () {
    test('normalizes local Ethiopian number', () {
      expect(normalizePaymentAccount('0946514836'), '251946514836');
      expect(normalizePaymentAccount('946514836'), '251946514836');
    });
  });

  group('isValidPaymentAccount', () {
    test('accepts normalized Ethiopian numbers', () {
      expect(isValidPaymentAccount('251946514836'), isTrue);
      expect(isValidPaymentAccount('946514836'), isTrue);
    });

    test('rejects empty or too-short values', () {
      expect(isValidPaymentAccount(null), isFalse);
      expect(isValidPaymentAccount(''), isFalse);
      expect(isValidPaymentAccount('123'), isFalse);
    });
  });
}
