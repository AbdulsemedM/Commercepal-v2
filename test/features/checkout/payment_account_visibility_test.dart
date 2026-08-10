import 'package:commercepal/features/checkout/data/models/payment_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentConstants.requiresPaymentAccount', () {
    test('requires phone for Telebirr, eBirr variants, Sahay, Amole, Waafi', () {
      expect(PaymentConstants.requiresPaymentAccount('TELEBIRR'), isTrue);
      expect(PaymentConstants.requiresPaymentAccount('TELE_BIRR'), isTrue);
      expect(PaymentConstants.requiresPaymentAccount('E_BIRR'), isTrue);
      expect(PaymentConstants.requiresPaymentAccount('EBIRR_COOPAY'), isTrue);
      expect(PaymentConstants.requiresPaymentAccount('EBIRR_KAFFI'), isTrue);
      expect(PaymentConstants.requiresPaymentAccount('SAHAY'), isTrue);
      expect(PaymentConstants.requiresPaymentAccount('AMOLE'), isTrue);
      expect(PaymentConstants.requiresPaymentAccount('WAAFI'), isTrue);
      expect(PaymentConstants.requiresPaymentAccount('EDAHAB'), isTrue);
    });

    test('does not require phone for CBE, PayPal, Ziina, COD', () {
      expect(PaymentConstants.requiresPaymentAccount('CBE_BIRR'), isFalse);
      expect(PaymentConstants.requiresPaymentAccount('PAYPAL'), isFalse);
      expect(PaymentConstants.requiresPaymentAccount('ZIINA'), isFalse);
      expect(PaymentConstants.requiresPaymentAccount('COD'), isFalse);
    });
  });

  group('PaymentConstants.shouldCollectPaymentAccount', () {
    test('uses allowlist even when API flag is false', () {
      expect(
        PaymentConstants.shouldCollectPaymentAccount(
          'TELEBIRR',
          apiRequiresAccount: false,
        ),
        isTrue,
      );
    });

    test('respects API flag for unknown providers', () {
      expect(
        PaymentConstants.shouldCollectPaymentAccount(
          'QPAY',
          apiRequiresAccount: true,
        ),
        isTrue,
      );
      expect(
        PaymentConstants.shouldCollectPaymentAccount(
          'QPAY',
          apiRequiresAccount: false,
        ),
        isFalse,
      );
    });

    test('never collects for excluded providers', () {
      expect(
        PaymentConstants.shouldCollectPaymentAccount(
          'CBE_BIRR',
          apiRequiresAccount: true,
        ),
        isFalse,
      );
    });
  });
}
