/// Payment provider codes from the public payment-methods API.
class PaymentProvider {
  PaymentProvider._();

  static const String telebirr = 'TELE_BIRR';
  static const String cbeBirr = 'CBE_BIRR';
  static const String edahab = 'EDAHAB';
  static const String eBirr = 'E_BIRR';
  static const String ziina = 'ZIINA';
  static const String paypal = 'PAYPAL';
  static const String qpay = 'QPAY';
  static const String sahay = 'SAHAY';
  static const String pesapal = 'PESAPAL';
  static const String waafi = 'WAAFI';
  static const String cod = 'COD';

  /// Providers that must open in an external browser (WebView blocked).
  static const Set<String> requiresExternalBrowser = <String>{
    ziina,
    paypal,
  };
}

/// Values for [PaymentInitiation.nextAction] after checkout / retry.
class NextAction {
  NextAction._();

  static const String redirectToPaymentUrl = 'REDIRECT_TO_PAYMENT_URL';
  static const String ussdCode = 'USSD_CODE';
  static const String scanQr = 'SCAN_QR';
  static const String showQrCode = 'SHOW_QR_CODE';
  static const String success = 'SUCCESS';
  static const String pending = 'PENDING';
  static const String openAdditionalInput = 'OPEN_ADDITIONAL_INPUT';
}

/// Payment status from GET /payments/order/{orderNumber}/status.
class PaymentStatus {
  PaymentStatus._();

  static const String pending = 'PENDING';
  static const String success = 'SUCCESS';
  static const String failed = 'FAILED';
  static const String cancelled = 'CANCELLED';
}

/// Order fulfillment stages.
class OrderStage {
  OrderStage._();

  static const String paymentPending = 'PAYMENT_PENDING';
  static const String paymentConfirmed = 'PAYMENT_CONFIRMED';
  static const String processing = 'PROCESSING';
  static const String packed = 'PACKED';
  static const String shipped = 'SHIPPED';
  static const String outForDelivery = 'OUT_FOR_DELIVERY';
  static const String delivered = 'DELIVERED';
}
