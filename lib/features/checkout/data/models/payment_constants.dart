/// Payment provider item codes (from payment methods API).
class PaymentConstants {
  PaymentConstants._();

  /// SahayPay under Mobile Money; requires phone/account verification before checkout.
  static const String sahayProviderCode = 'SAHAY';

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
