import 'package:commercepal/features/checkout/data/models/checkout_response.dart';
import 'package:commercepal/features/checkout/data/models/payment_flow_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutResponse.isCheckoutCompleteForCartClear', () {
    test('true when nextAction is SUCCESS', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-1',
        'paymentInitiation': <String, dynamic>{
          'nextAction': NextAction.success,
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isTrue);
    });

    test('true when paymentStatus is SUCCESS', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-2',
        'paymentStatus': PaymentStatus.success,
      });
      expect(r.isCheckoutCompleteForCartClear, isTrue);
    });

    test('false for REDIRECT even with paymentUrl', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-2',
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'ORD-2',
          'paymentReference': 'CP-2',
          'paymentUrl': 'https://pay.example.com/x',
          'nextAction': NextAction.redirectToPaymentUrl,
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isFalse);
    });

    test('isOrderReservedPaymentPending when PENDING with order number', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'CPA07235J62MECH',
        'paymentStatus': 'PENDING',
        'paymentInitiation': <String, dynamic>{
          'success': false,
          'orderNumber': 'CPA07235J62MECH',
          'paymentReference': 'CP-20260723-3X7TXGB6',
          'nextAction': NextAction.openAdditionalInput,
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isFalse);
      expect(r.isOrderReservedPaymentPending, isTrue);
    });
  });
}
