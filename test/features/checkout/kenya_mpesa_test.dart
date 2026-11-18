import 'package:flutter_test/flutter_test.dart';

import 'package:commercepal/features/checkout/data/models/payment_constants.dart';
import 'package:commercepal/features/checkout/presentation/utils/payment_phone_utils.dart';

void main() {
  test('Kenyan shoppers see only M-Pesa (KasaPay) and PayPal', () {
    expect(PaymentConstants.isAllowedForCurrency('KASAPAY_MPESA_KEN', 'KES'),
        isTrue);
    expect(PaymentConstants.isAllowedForCurrency('PAYPAL', 'KES'), isTrue);
    expect(PaymentConstants.isAllowedForCurrency('TELE_BIRR', 'KES'), isFalse);
    expect(PaymentConstants.isAllowedForCurrency('KASAPAY_MPESA_KEN', 'ETB'),
        isFalse);
    expect(PaymentConstants.isAllowedForCurrency('TELE_BIRR', 'ETB'), isTrue);
  });

  test('M-Pesa Kenya collects a phone number', () {
    expect(PaymentConstants.requiresPaymentAccount('KASAPAY_MPESA_KEN'), isTrue);
  });

  test('Kenyan numbers normalize to 254, not 251', () {
    expect(normalizePaymentAccount('0712 345 678', countryCode: 'KE'),
        '254712345678');
    expect(normalizePaymentAccount('+254712345678', countryCode: 'KE'),
        '254712345678');
    expect(isValidKenyanMpesaNumber('0712345678'), isTrue);
    expect(isValidKenyanMpesaNumber('0112345678'), isTrue);
    expect(isValidKenyanMpesaNumber('0912345678'), isFalse);
    // Ethiopian behaviour unchanged.
    expect(normalizePaymentAccount('0912345678'), '251912345678');
  });

  test('a stored Kenyan phone pre-fills as Kenya', () {
    final parsed = parseProfilePhoneForField('254702816862');
    expect(parsed.initialCountryCode, 'KE');
    expect(parsed.localNumber, '702816862');
  });
}
