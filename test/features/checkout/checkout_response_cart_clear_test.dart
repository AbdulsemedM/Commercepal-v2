import 'package:commercepal/features/checkout/data/models/checkout_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutResponse.isCheckoutCompleteForCartClear', () {
    test('true for OPEN_ADDITIONAL_INPUT with full initiation', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-1',
        'currency': 'ETB',
        'paymentStatus': 'PENDING',
        'pricingSummary': <String, dynamic>{
          'subtotal': 1870.20,
          'totalAmount': 1870.20,
          'currency': 'ETB',
        },
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'ORD-1',
          'paymentReference': 'CP-REF',
          'paymentProviderCode': null,
          'paymentUrl': null,
          'paymentInstructions': 'Please complete the payment on your phone',
          'nextAction': 'OPEN_ADDITIONAL_INPUT',
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isTrue);
    });

    test('true for REDIRECT when paymentUrl present', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-2',
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'ORD-2',
          'paymentReference': 'CP-2',
          'paymentUrl': 'https://pay.example.com/x',
          'nextAction': 'REDIRECT_TO_PAYMENT_URL',
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isTrue);
    });

    test('false when success is false', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-1',
        'paymentInitiation': <String, dynamic>{
          'success': false,
          'orderNumber': 'ORD-1',
          'paymentReference': 'CP-REF',
          'paymentInstructions': 'x',
          'nextAction': 'OPEN_ADDITIONAL_INPUT',
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isFalse);
    });

    test('false when paymentReference missing', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-1',
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'ORD-1',
          'paymentInstructions': 'x',
          'nextAction': 'OPEN_ADDITIONAL_INPUT',
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isFalse);
    });

    test('false when OPEN_ADDITIONAL_INPUT but instructions empty', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-1',
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'ORD-1',
          'paymentReference': 'CP-REF',
          'paymentInstructions': '   ',
          'nextAction': 'OPEN_ADDITIONAL_INPUT',
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isFalse);
    });

    test('false when REDIRECT without paymentUrl', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-1',
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'ORD-1',
          'paymentReference': 'CP-REF',
          'nextAction': 'REDIRECT_TO_PAYMENT_URL',
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isFalse);
    });

    test('false when order numbers mismatch', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-A',
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'ORD-B',
          'paymentReference': 'CP-REF',
          'paymentInstructions': 'x',
          'nextAction': 'OPEN_ADDITIONAL_INPUT',
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isFalse);
    });

    test('true for SCAN_QR when QR payload present', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'CPA0723FB6U6ZS7',
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'CPA0723FB6U6ZS7',
          'paymentReference': 'CP-20260723-Q37HLKD3',
          'paymentUrl': '00020101021128370007RMFI',
          'nextAction': 'SCAN_QR',
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isTrue);
    });

    test('false for unknown nextAction', () {
      final r = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'ORD-1',
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'ORD-1',
          'paymentReference': 'CP-REF',
          'paymentInstructions': 'x',
          'nextAction': 'UNKNOWN',
        },
      });
      expect(r.isCheckoutCompleteForCartClear, isFalse);
    });
  });
}
