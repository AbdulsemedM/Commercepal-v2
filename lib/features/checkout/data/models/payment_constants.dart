import 'checkout_request.dart';

/// Payment provider item codes (from payment methods API).
class PaymentConstants {
  PaymentConstants._();

  /// Docs checkout payment methods.
  static const Set<String> docsPaymentProviderCodes = <String>{
    'TELEBIRR',
    'CBE_BIRR',
    'E_BIRR',
    'ZIINA',
  };

  static bool usesDocsPaymentFlow(String? code, {String? displayName}) {
    return toDocsPaymentMethod(code, displayName: displayName) != null;
  }

  @Deprecated('Use usesDocsPaymentFlow')
  static bool usesDocsCheckoutFlow(String? code, {String? displayName}) {
    return usesDocsPaymentFlow(code, displayName: displayName);
  }

  static DocsPaymentMethod? toDocsPaymentMethod(
    String? code, {
    String? displayName,
  }) {
    final String haystack = _normalizedHaystack(code, displayName);
    if (haystack.isEmpty) return null;

    if (haystack.contains('TELEBIRR')) {
      return DocsPaymentMethod.telebirr;
    }
    if (haystack.contains('CBEBIRR') || haystack == 'CBE') {
      return DocsPaymentMethod.cbeBirr;
    }
    if (haystack.contains('EDAHAB') ||
        haystack.contains('EBIRR') ||
        haystack.contains('EBIR')) {
      return DocsPaymentMethod.eBirr;
    }
    if (haystack.contains('ZIINA')) {
      return DocsPaymentMethod.ziina;
    }

    final String? normalizedCode = code?.trim().toUpperCase();
    if (normalizedCode != null && docsPaymentProviderCodes.contains(normalizedCode)) {
      switch (normalizedCode) {
        case 'TELEBIRR':
          return DocsPaymentMethod.telebirr;
        case 'CBE_BIRR':
          return DocsPaymentMethod.cbeBirr;
        case 'E_BIRR':
          return DocsPaymentMethod.eBirr;
        case 'ZIINA':
          return DocsPaymentMethod.ziina;
      }
    }
    return null;
  }

  static bool requiresPhoneForDocsCheckout(DocsPaymentMethod method) {
    return method == DocsPaymentMethod.telebirr ||
        method == DocsPaymentMethod.eBirr;
  }

  static bool isCbeBirr(String? code, {String? displayName}) {
    return toDocsPaymentMethod(code, displayName: displayName) ==
        DocsPaymentMethod.cbeBirr;
  }

  static bool isZiina(String? code, {String? displayName}) {
    return toDocsPaymentMethod(code, displayName: displayName) ==
        DocsPaymentMethod.ziina;
  }

  static bool usesDocsUssdFlow(DocsPaymentMethod method) {
    return method == DocsPaymentMethod.telebirr ||
        method == DocsPaymentMethod.eBirr;
  }

  static bool usesDocsWebViewFlow(DocsPaymentMethod method) {
    return method == DocsPaymentMethod.cbeBirr ||
        method == DocsPaymentMethod.ziina;
  }

  /// SahayPay under Mobile Money; requires phone/account verification before checkout.
  static const String sahayProviderCode = 'SAHAY';

  /// PayPal checkout; no phone account. Supported when cart currency has FX data.
  static const String paypalProviderCode = 'PAYPAL';

  static bool isPayPal(String? code) {
    if (code == null || code.isEmpty) return false;
    return code.toUpperCase() == paypalProviderCode;
  }

  /// Cart currencies that may use PayPal regardless of method currency from API.
  static const Set<String> paypalSupportedCartCurrencies = <String>{
    'ETB',
    'USD',
    'KES',
    'SOS',
    'AED',
  };

  static bool isPayPalSupportedCartCurrency(String? currency) {
    if (currency == null || currency.isEmpty) return false;
    return paypalSupportedCartCurrencies.contains(currency.toUpperCase());
  }

  /// Temporarily hidden from payment selection (re-enable when ready).
  static const Set<String> hiddenPaymentProviderCodes = <String>{};

  static String _normalizedHaystack(String? code, String? displayName) {
    return '${code ?? ''} ${displayName ?? ''}'
        .toUpperCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '');
  }

  static bool isHiddenPaymentProvider(String? code, {String? displayName}) {
    final String haystack = _normalizedHaystack(code, displayName);
    if (haystack.isEmpty) return false;
    return code != null &&
        code.isNotEmpty &&
        hiddenPaymentProviderCodes.contains(code.toUpperCase());
  }

  static bool isTelebirr(String? code, {String? displayName}) {
    return _normalizedHaystack(code, displayName).contains('TELEBIRR');
  }

  static bool isEdahab(String? code, {String? displayName}) {
    return _normalizedHaystack(code, displayName).contains('EDAHAB');
  }

  static bool usesDocsInitiateFlow(String? code, {String? displayName}) {
    return isTelebirr(code, displayName: displayName) ||
        isEdahab(code, displayName: displayName);
  }

  static bool isQPay(String? code, {String? displayName}) {
    final String haystack =
        '${code ?? ''} ${displayName ?? ''}'.toUpperCase().replaceAll(
              RegExp(r'[\s_\-]+'),
              '',
            );
    return haystack.contains('QPAY');
  }

  /// Provider codes that initiate USSD payment; show "USSD payment initiated" success popup after checkout.
  /// CBE_BIRR is excluded: we redirect straight to payment URL without USSD confirmation.
  static const Set<String> ussdPaymentProviderCodes = <String>{
    'TELEBIRR',
    'EBIRR_COOPAY',
    'EBIRR_KAFFI',
    'SAHAY',
    'PESAPAL',
  };

  static bool isUssdPaymentProvider(String? code) {
    if (code == null || code.isEmpty) return false;
    return ussdPaymentProviderCodes.contains(code.toUpperCase());
  }

  /// Provider codes for cash-on-delivery checkout (no online payment step).
  static const Set<String> cashOnDeliveryProviderCodes = <String>{
    'CASH',
    'CASH_ON_DELIVERY',
    'COD',
  };

  static bool isCashOnDelivery(String? code) {
    if (code == null || code.isEmpty) return false;
    return cashOnDeliveryProviderCodes.contains(code.toUpperCase());
  }
}
