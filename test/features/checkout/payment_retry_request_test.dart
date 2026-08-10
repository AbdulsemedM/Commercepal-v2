import 'package:commercepal/features/checkout/data/models/payment_retry_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PaymentRetryRequest serializes order retry body', () {
    final request = PaymentRetryRequest(
      paymentProviderCode: 'TELEBIRR',
      paymentAccount: '+251911234567',
    );

    expect(request.toJson(), <String, dynamic>{
      'paymentProviderCode': 'TELEBIRR',
      'paymentAccount': '+251911234567',
    });
  });
}
