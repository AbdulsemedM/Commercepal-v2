import 'package:commercepal/features/checkout/data/models/checkout_response.dart';
import 'package:commercepal/features/checkout/presentation/screen/qpay_qr_payment_screen.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CheckoutResponse _sampleQpayResponse() {
  return CheckoutResponse.fromJson(<String, dynamic>{
    'orderNumber': 'CPA08103YWUU8P4',
    'paymentStatus': 'PENDING',
    'currency': 'ETB',
    'pricingSummary': <String, dynamic>{
      'totalAmount': 1500,
      'currency': 'ETB',
    },
    'paymentInitiation': <String, dynamic>{
      'success': true,
      'orderNumber': 'CPA08103YWUU8P4',
      'paymentProviderCode': 'QPAY',
      'nextAction': 'SHOW_QR_CODE',
      'qrData': '00020101021226580016COM.MPESA123456789012345678901234567890123456789012345678901234567890520400005303404540510.005802ET5913CommercePal6009AddisAbaba6304ABCD',
    },
  });
}

Future<void> _pumpQpayScreen(
  WidgetTester tester, {
  bool paymentConfirmed = false,
}) async {
  await LocalizationService.ensureInitialized();
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: QpayQrPaymentScreen(
        response: _sampleQpayResponse(),
        initialPaymentConfirmed: paymentConfirmed,
        disablePaymentPolling: true,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('QpayQrPaymentScreen save QR UI', () {
    testWidgets('shows save button while payment is pending', (tester) async {
      await _pumpQpayScreen(tester);

      expect(find.byKey(const Key('qpay_save_qr_button')), findsOneWidget);
      expect(find.text('Save QR to Gallery'), findsOneWidget);
      expect(
        find.textContaining('Save this QR code to your gallery'),
        findsOneWidget,
      );
    });

    testWidgets('hides save button after payment is confirmed', (tester) async {
      await _pumpQpayScreen(tester, paymentConfirmed: true);

      expect(find.byKey(const Key('qpay_save_qr_button')), findsNothing);
      expect(find.text('Save QR to Gallery'), findsNothing);
      expect(
        find.textContaining('Save this QR code to your gallery'),
        findsNothing,
      );
    });
  });
}
