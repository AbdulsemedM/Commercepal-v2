import 'package:flutter/material.dart';

/// Local payment-method logos shipped with the app.
class PaymentMethodAssets {
  PaymentMethodAssets._();

  static const String airtel = 'assets/images/airtel.png';
  static const String cashOnDelivery = 'assets/images/cash on delivery.png';
  static const String cbeBirr = 'assets/images/cbe birr.jpg';
  static const String debitCreditCard = 'assets/images/debit-credit card.png';
  static const String ebirr = 'assets/images/ebirr.png';
  static const String pesapal = 'assets/images/pesapal.png';
  static const String pesapalWallet = 'assets/images/pesapal-wallet.png';
  static const String qpay = 'assets/images/qpay.png';
  static const String telebirr = 'assets/images/telebirr.png';

  /// Resolves a local asset path from payment method id and/or display name.
  static String? assetPathFor({
    String? id,
    String? name,
    String? code,
  }) {
    final String key = '$id $name $code'.toLowerCase();

    if (key.contains('telebirr') || key.contains('tele birr')) {
      return telebirr;
    }
    if (key.contains('airtel')) {
      return airtel;
    }
    if (key.contains('cash on delivery') ||
        key.contains('cash_on_delivery') ||
        RegExp(r'\bcod\b').hasMatch(key) ||
        (key.contains('cash') && key.contains('delivery'))) {
      return cashOnDelivery;
    }
    if (key.contains('cbe') || key.contains('commercial bank')) {
      return cbeBirr;
    }
    if (key.contains('pesapal') && key.contains('wallet')) {
      return pesapalWallet;
    }
    if (key.contains('pesapal')) {
      return pesapal;
    }
    if (key.contains('ebirr') ||
        key.contains('e-birr') ||
        key.contains('coopay') ||
        key.contains('kaffi')) {
      return ebirr;
    }
    if (key.contains('qpay') || key.contains('q-pay')) {
      return qpay;
    }
    if (key.contains('debit') ||
        key.contains('credit') ||
        key.contains('visa') ||
        key.contains('master') ||
        RegExp(r'\bcard\b').hasMatch(key)) {
      return debitCreditCard;
    }
    return null;
  }

  /// Local asset first, then optional network [iconUrl], then [fallback].
  static Widget logo({
    required double size,
    String? id,
    String? name,
    String? code,
    String? iconUrl,
    Widget? fallback,
  }) {
    final Widget iconFallback =
        fallback ?? Icon(Icons.payment_outlined, size: size * 0.65);

    final String? assetPath = assetPathFor(id: id, name: name, code: code);
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => iconFallback,
      );
    }

    final String? resolved = _resolveNetworkUrl(iconUrl);
    if (resolved != null) {
      return Image.network(
        resolved,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => iconFallback,
      );
    }

    return iconFallback;
  }

  static String? _resolveNetworkUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return 'https://commercepal.com$url';
    return null;
  }
}
