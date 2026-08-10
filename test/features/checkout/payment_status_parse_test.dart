import 'package:flutter_test/flutter_test.dart';

import 'package:commercepal/features/checkout/data/models/payment_constants.dart';
import 'package:commercepal/features/checkout/data/models/payment_initiate_result.dart';
import 'package:commercepal/features/checkout/data/models/payment_status_result.dart';

void main() {
  group('PaymentInitiateResult', () {
    test('parses nested telebirr initiate payload', () {
      final result = PaymentInitiateResult.fromJson(<String, dynamic>{
        'status': 200,
        'data': <String, dynamic>{
          'ussdCode': '*127*1*2*3#',
          'referenceCode': 'REF-123',
        },
      });

      expect(result.ussdCode, '*127*1*2*3#');
      expect(result.referenceCode, 'REF-123');
      expect(result.resolvedReference, 'REF-123');
    });

    test('parses flat edahab initiate payload', () {
      final result = PaymentInitiateResult.fromJson(<String, dynamic>{
        'message': 'Complete payment on your phone',
        'referenceNumber': 'ED-99',
      });

      expect(result.message, 'Complete payment on your phone');
      expect(result.referenceNumber, 'ED-99');
      expect(result.resolvedReference, 'ED-99');
    });
  });

  group('PaymentStatusResult', () {
    test('parses success status from nested data', () {
      final result = PaymentStatusResult.fromJson(<String, dynamic>{
        'status': 200,
        'data': <String, dynamic>{
          'paymentStatus': 'SUCCESS',
          'orderStatus': 'PAYMENT_CONFIRMED',
        },
      });

      expect(result.isSuccess, isTrue);
      expect(result.isFailed, isFalse);
      expect(result.orderStatus, 'PAYMENT_CONFIRMED');
    });

    test('treats pending as not terminal', () {
      final result = PaymentStatusResult.fromJson(<String, dynamic>{
        'paymentStatus': 'PENDING',
      });

      expect(result.isPending, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.isFailed, isFalse);
    });
  });

  group('PaymentConstants', () {
    test('detects telebirr and edahab providers', () {
      expect(PaymentConstants.isTelebirr('TELEBIRR'), isTrue);
      expect(PaymentConstants.isEdahab('E_DAHAB'), isTrue);
      expect(
        PaymentConstants.usesDocsInitiateFlow('TELEBIRR'),
        isTrue,
      );
      expect(
        PaymentConstants.usesDocsInitiateFlow('PAYPAL'),
        isFalse,
      );
    });

    test('does not hide telebirr anymore', () {
      expect(
        PaymentConstants.isHiddenPaymentProvider('TELEBIRR'),
        isFalse,
      );
    });
  });
}
