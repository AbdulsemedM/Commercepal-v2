/// Payment provider item codes (from payment methods API).
class PaymentConstants {
  PaymentConstants._();

  /// SahayPay under Mobile Money; requires phone/account verification before checkout.
  static const String sahayProviderCode = 'SAHAY';

  /// Provider codes that initiate USSD payment; show "USSD payment initiated" success popup after checkout.
  static const Set<String> ussdPaymentProviderCodes = <String>{
    'TELEBIRR',
    'EBIRR_COOPAY',
    'EBIRR_KAFFI',
    'CBE_BIRR',
    'SAHAY',
    'PESAPAL',
  };

  static bool isUssdPaymentProvider(String? code) {
    if (code == null || code.isEmpty) return false;
    return ussdPaymentProviderCodes.contains(code.toUpperCase());
  }
}
