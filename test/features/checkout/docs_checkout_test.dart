import 'package:commercepal/features/addresses/data/models/address.dart';
import 'package:commercepal/features/checkout/data/models/checkout_request.dart';
import 'package:commercepal/features/checkout/data/models/checkout_response.dart';
import 'package:commercepal/features/checkout/data/models/payment_constants.dart';
import 'package:commercepal/features/checkout/data/models/payment_flow_constants.dart';
import 'package:commercepal/features/checkout/data/models/payment_initiate_result.dart';
import 'package:commercepal/features/checkout/data/models/public_payment_method.dart';
import 'package:commercepal/features/checkout/data/models/shipping_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShippingAddress.fromAddress', () {
    test('maps address model fields', () {
      final address = Address(
        id: 1,
        isDefault: true,
        canEdit: true,
        canDelete: true,
        receiverName: 'Jane Doe',
        phoneNumber: '+251900000000',
        country: 'ET',
        state: 'Addis Ababa',
        city: 'Addis Ababa',
        district: 'Bole',
        street: 'Main St',
        houseNumber: '12',
        addressLine1: 'Main St 12',
        latitude: '0',
        longitude: '0',
        addressSource: 'MANUAL',
      );

      final shipping = ShippingAddress.fromAddress(address);

      expect(shipping.fullName, 'Jane Doe');
      expect(shipping.phone, '+251900000000');
      expect(shipping.address, 'Main St 12');
      expect(shipping.city, 'Addis Ababa');
      expect(shipping.country, 'ET');
    });
  });

  group('CheckoutResponse guide fields', () {
    test('parses paymentInitiation with ussd and instructions', () {
      final response = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'CPA0808XXXXX',
        'paymentStatus': 'PENDING',
        'paymentInitiation': <String, dynamic>{
          'nextAction': 'USSD_CODE',
          'ussdCode': '*127*1#',
          'instructions': 'Dial on your phone',
          'paymentUrl': 'https://pay.example.com',
        },
      });

      expect(response.resolvedNextAction, 'USSD_CODE');
      expect(response.resolvedUssdCode, '*127*1#');
      expect(
        response.paymentInitiation?.resolvedInstructions,
        'Dial on your phone',
      );
      expect(response.isCheckoutCompleteForCartClear, isFalse);
    });

    test('cart clear only on SUCCESS nextAction', () {
      final cod = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'CPA-COD',
        'paymentInitiation': <String, dynamic>{
          'nextAction': NextAction.success,
        },
      });
      expect(cod.isCheckoutCompleteForCartClear, isTrue);

      final pending = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'CPA-PEND',
        'paymentInitiation': <String, dynamic>{
          'nextAction': NextAction.redirectToPaymentUrl,
          'paymentUrl': 'https://pay.example.com',
        },
      });
      expect(pending.isCheckoutCompleteForCartClear, isFalse);
    });
  });

  group('PublicPaymentMethod', () {
    test('parses flat public API item', () {
      final method = PublicPaymentMethod.fromJson(<String, dynamic>{
        'providerCode': 'TELEBIRR',
        'displayName': 'Telebirr',
        'requiresAccount': true,
        'isEnabled': true,
        'sortOrder': 1,
      });

      expect(method.providerCode, 'TELEBIRR');
      expect(method.requiresAccount, isTrue);
    });
  });

  group('PaymentConstants docs mapping', () {
    test('maps provider codes to docs payment methods', () {
      expect(
        PaymentConstants.toDocsPaymentMethod('TELEBIRR'),
        DocsPaymentMethod.telebirr,
      );
      expect(PaymentConstants.requiresExternalBrowser('PAYPAL'), isTrue);
      expect(PaymentConstants.requiresExternalBrowser('TELEBIRR'), isFalse);
    });
  });

  group('PaymentInitiateResult CBE parse', () {
    test('parses cbe-birr initiate response', () {
      final result = PaymentInitiateResult.fromJson(<String, dynamic>{
        'status': 200,
        'data': <String, dynamic>{
          'paymentUrl': 'https://cbe.example.com/pay',
          'referenceNumber': 'CBE-123',
        },
      });

      expect(result.paymentUrl, 'https://cbe.example.com/pay');
      expect(result.resolvedReference, 'CBE-123');
    });
  });
}
