import 'checkout_request.dart';
import 'payment_flow_constants.dart';

/// Payment provider item codes (from payment methods API).
class PaymentConstants {
  PaymentConstants._();

  /// Docs / web checkout payment methods.
  static const Set<String> docsPaymentProviderCodes = <String>{
    'TELEBIRR',
    'TELE_BIRR',
    'CBE_BIRR',
    'E_BIRR',
    'ZIINA',
  };

  /// Maps UI/API provider codes to the codes production web checkout sends.
  static String toCheckoutProviderCode(String code) {
    final String normalized = code.trim().toUpperCase();
    if (normalized == 'TELEBIRR' || normalized == 'TELE_BIRR') {
      return 'TELE_BIRR';
    }
    return normalized;
  }

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
    if (normalizedCode != null &&
        docsPaymentProviderCodes.contains(normalizedCode)) {
      switch (normalizedCode) {
        case 'TELEBIRR':
        case 'TELE_BIRR':
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

  /// eBirr variants (E_BIRR, EBIRR_COOPAY, EBIRR_KAFFI); excludes Telebirr and CBE Birr.
  static bool isEbirr(String? code, {String? displayName}) {
    return toDocsPaymentMethod(code, displayName: displayName) ==
        DocsPaymentMethod.eBirr;
  }

  /// Checkout list order: QPay (0), eBirr (1), CBE Birr (2), then everything else (3).
  static int checkoutDisplaySortRank(String? code, {String? displayName}) {
    if (isQPay(code, displayName: displayName)) return 0;
    if (isEbirr(code, displayName: displayName)) return 1;
    if (isCbeBirr(code, displayName: displayName)) return 2;
    return 3;
  }

  /// Provider codes that initiate USSD payment; show "USSD payment initiated" success popup after checkout.
  /// CBE_BIRR is excluded: we redirect straight to payment URL without USSD confirmation.
  static const Set<String> ussdPaymentProviderCodes = <String>{
    'TELEBIRR',
    'TELE_BIRR',
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

  /// Providers that never collect a phone/account at checkout.
  static bool requiresNoPaymentAccount(String? code, {String? displayName}) {
    return isPayPal(code) ||
        isCbeBirr(code, displayName: displayName) ||
        isZiina(code, displayName: displayName) ||
        isCashOnDelivery(code);
  }

  /// Explicit allowlist: providers that need phone/account regardless of API flag.
  static bool requiresPaymentAccount(String? code, {String? displayName}) {
    if (code == null || code.isEmpty) return false;
    if (requiresNoPaymentAccount(code, displayName: displayName)) {
      return false;
    }

    final String haystack = _normalizedHaystack(code, displayName);
    if (haystack.isEmpty) return false;

    if (haystack.contains('TELEBIRR')) return true;
    if (haystack.contains('EDAHAB')) return true;
    if (haystack.contains('SAHAY')) return true;
    if (haystack.contains('AMOLE')) return true;
    if (haystack.contains('WAAFI')) return true;

    // eBirr variants (E_BIRR, EBIRR_COOPAY, EBIRR_KAFFI); CBE_BIRR excluded above.
    if (haystack.contains('EBIRR') || haystack.contains('EBIR')) return true;

    return false;
  }

  /// Whether checkout UI should show and validate the payment phone/account field.
  static bool shouldCollectPaymentAccount(
    String? code, {
    String? displayName,
    bool apiRequiresAccount = false,
    bool? legacyRequireAccountOnInitiation,
  }) {
    if (requiresNoPaymentAccount(code, displayName: displayName)) {
      return false;
    }
    return requiresPaymentAccount(code, displayName: displayName) ||
        apiRequiresAccount ||
        legacyRequireAccountOnInitiation == true;
  }

  static bool isSahay(String? code, {String? displayName}) {
    final String haystack = _normalizedHaystack(code, displayName);
    return haystack.contains('SAHAY');
  }

  static bool isAmole(String? code, {String? displayName}) {
    final String haystack = _normalizedHaystack(code, displayName);
    return haystack.contains('AMOLE');
  }

  static bool isWaafi(String? code, {String? displayName}) {
    final String haystack = _normalizedHaystack(code, displayName);
    return haystack.contains('WAAFI');
  }

  static bool requiresExternalBrowser(String? code) {
    if (code == null || code.isEmpty) return false;
    return PaymentProvider.requiresExternalBrowser.contains(code.toUpperCase());
  }
}
