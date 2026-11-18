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

  test('PaymentRetryRequest builds the backend /payments/retry body', () {
    final request = PaymentRetryRequest(
      paymentProviderCode: 'TELE_BIRR',
      paymentAccount: '251912345678',
    );

    expect(request.toBackendJson('CPA1118YH9YN2EE'), <String, dynamic>{
      'paymentReference': 'CPA1118YH9YN2EE',
      'paymentProviderCode': 'TELE_BIRR',
    });
  });
}
