import 'package:flutter_test/flutter_test.dart';

import 'package:commercepal/core/auth/express_checkout.dart';

void main() {
  group('ExpressCheckout.isAllowedRequest', () {
    test('allows placing and paying for an order', () {
      expect(ExpressCheckout.isAllowedRequest('POST', '/api/orders/checkout'),
          isTrue);
      expect(ExpressCheckout.isAllowedRequest('POST', '/api/customers/addresses'),
          isTrue);
      expect(ExpressCheckout.isAllowedRequest('GET', '/api/payment-methods'),
          isTrue);
      expect(ExpressCheckout.isAllowedRequest('POST', '/api/payments/retry'),
          isTrue);
      expect(
          ExpressCheckout.isAllowedRequest(
              'GET', '/api/payments/order/CPA1118YH9YN2EE/status'),
          isTrue);
      expect(ExpressCheckout.isAllowedRequest('GET', '/api/orders/CPA1118YH9YN2EE'),
          isTrue);
    });

    test('never sends the express token to account endpoints', () {
      expect(ExpressCheckout.isAllowedRequest('GET', '/api/customers/addresses'),
          isFalse);
      expect(
          ExpressCheckout.isAllowedRequest('PUT', '/api/customers/addresses/5'),
          isFalse);
      expect(ExpressCheckout.isAllowedRequest('GET', '/api/orders'), isFalse);
      expect(ExpressCheckout.isAllowedRequest('GET', '/api/customers/profile'),
          isFalse);
      expect(ExpressCheckout.isAllowedRequest('GET', '/api/wallet'), isFalse);
      expect(ExpressCheckout.isAllowedRequest('GET', '/api/wishlist'), isFalse);
    });

    test('accepts /api/v1 paths and full URLs', () {
      expect(
          ExpressCheckout.isAllowedRequest(
              'POST', 'https://commercepal.com/api/v1/orders/checkout'),
          isTrue);
    });
  });
}
