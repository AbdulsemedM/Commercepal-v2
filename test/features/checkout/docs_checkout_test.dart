import 'package:commercepal/features/addresses/data/models/address.dart';
import 'package:commercepal/features/checkout/data/models/checkout_request.dart';
import 'package:commercepal/features/checkout/data/models/checkout_response.dart';
import 'package:commercepal/features/checkout/data/models/payment_constants.dart';
import 'package:commercepal/features/checkout/data/models/payment_initiate_result.dart';
import 'package:commercepal/features/checkout/data/models/shipping_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocsCheckoutRequest', () {
    test('serializes cartId shippingAddress and paymentMethod', () {
      final request = DocsCheckoutRequest(
        cartId: 123,
        shippingAddress: const ShippingAddress(
          fullName: 'John Doe',
          phone: '+251911234567',
          address: 'Bole Road',
          city: 'Addis Ababa',
          country: 'ET',
        ),
        paymentMethod: DocsPaymentMethod.telebirr,
        notes: '',
      );

      expect(request.toJson(), <String, dynamic>{
        'cartId': 123,
        'shippingAddress': <String, dynamic>{
          'fullName': 'John Doe',
          'phone': '+251911234567',
          'address': 'Bole Road',
          'city': 'Addis Ababa',
          'country': 'ET',
        },
        'paymentMethod': 'TELEBIRR',
        'notes': '',
      });
    });
  });

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

  group('CheckoutResponse docs fields', () {
    test('parses docs checkout response', () {
      final response = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'CPA0808XXXXX',
        'paymentUrl': 'https://pay.example.com',
        'ussdCode': '*127*1#',
        'totalAmount': 2636.0,
      });

      expect(response.isDocsCheckoutResponse, isTrue);
      expect(response.isDocsCheckoutCompleteForCartClear, isTrue);
      expect(response.resolvedTotalAmount, 2636.0);
      expect(response.paymentUrl, 'https://pay.example.com');
      expect(response.ussdCode, '*127*1#');
    });
  });

  group('PaymentConstants docs mapping', () {
    test('maps provider codes to docs payment methods', () {
      expect(
        PaymentConstants.toDocsPaymentMethod('TELEBIRR'),
        DocsPaymentMethod.telebirr,
      );
      expect(
        PaymentConstants.toDocsPaymentMethod('CBE_BIRR'),
        DocsPaymentMethod.cbeBirr,
      );
      expect(
        PaymentConstants.toDocsPaymentMethod('EDAHAB'),
        DocsPaymentMethod.eBirr,
      );
      expect(
        PaymentConstants.toDocsPaymentMethod('ZIINA'),
        DocsPaymentMethod.ziina,
      );
      expect(PaymentConstants.usesDocsPaymentFlow('PAYPAL'), isFalse);
    });

    test('phone required only for Telebirr and E_BIRR', () {
      expect(
        PaymentConstants.requiresPhoneForDocsCheckout(DocsPaymentMethod.telebirr),
        isTrue,
      );
      expect(
        PaymentConstants.requiresPhoneForDocsCheckout(DocsPaymentMethod.eBirr),
        isTrue,
      );
      expect(
        PaymentConstants.requiresPhoneForDocsCheckout(DocsPaymentMethod.cbeBirr),
        isFalse,
      );
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
