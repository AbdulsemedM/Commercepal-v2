/// Payment provider item codes (from payment methods API).
class PaymentConstants {
  PaymentConstants._();

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
  static const Set<String> hiddenPaymentProviderCodes = <String>{
    'TELEBIRR',
  };

  static bool isHiddenPaymentProvider(String? code) {
    if (code == null || code.isEmpty) return false;
    return hiddenPaymentProviderCodes.contains(code.toUpperCase());
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
