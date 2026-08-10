import 'package:commercepal/features/checkout/data/models/checkout_response.dart';
import 'package:commercepal/features/checkout/data/models/payment_flow_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SHOW_QR_CODE QPay response', () {
    test('parses SHOW_QR_CODE nextAction and qr fields', () {
      final response = CheckoutResponse.fromJson(<String, dynamic>{
        'orderNumber': 'CPA08103YWUU8P4',
        'paymentStatus': 'PENDING',
        'paymentInitiation': <String, dynamic>{
          'success': true,
          'orderNumber': 'CPA08103YWUU8P4',
          'paymentReference': 'CP-20260810-6D6JNDJ6',
          'paymentProviderCode': 'QPAY',
          'paymentUrl': '000201-from-url',
          'paymentInstructions': 'Scan the QR code',
          'nextAction': 'SHOW_QR_CODE',
          'qrCode': '000201-from-qrCode',
          'qrData': '000201-from-qrData',
        },
      });

      expect(response.resolvedNextAction, NextAction.showQrCode);
      expect(response.resolvedQrPayload, '000201-from-qrData');
    });

    test('resolvedQrPayload prefers qrData over qrCode over paymentUrl', () {
      final withQrData = PaymentInitiation.fromJson(<String, dynamic>{
        'qrData': 'data',
        'qrCode': 'code',
        'paymentUrl': 'url',
      });
      expect(withQrData.resolvedQrPayload, 'data');

      final withQrCode = PaymentInitiation.fromJson(<String, dynamic>{
        'qrCode': 'code',
        'paymentUrl': 'url',
      });
      expect(withQrCode.resolvedQrPayload, 'code');

      final withUrl = PaymentInitiation.fromJson(<String, dynamic>{
        'paymentUrl': 'url',
      });
      expect(withUrl.resolvedQrPayload, 'url');
    });

    test('SCAN_QR and SHOW_QR_CODE are both QR next-actions', () {
      expect(NextAction.scanQr, 'SCAN_QR');
      expect(NextAction.showQrCode, 'SHOW_QR_CODE');
      expect(
        CheckoutResponse.nextActionShowQrCode,
        NextAction.showQrCode,
      );
    });
  });
}
