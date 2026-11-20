import 'package:commercepal/core/utils/phone_utils.dart';
import 'package:commercepal/features/profile/data/repository/profile_repository.dart';

/// Parsed phone values for pre-filling [IntlPhoneField].
class ParsedPhoneForField {
  const ParsedPhoneForField({
    required this.initialCountryCode,
    required this.localNumber,
    required this.completeNumber,
  });

  final String initialCountryCode;
  final String localNumber;
  final String completeNumber;
}

/// Loads profile phone first, then optional delivery-address fallback.
Future<String?> loadDefaultPaymentPhone({String? fallbackPhone}) async {
  final cached = await ProfileRepository().getCachedProfile();
  final profilePhone = cached?.profile.phoneNumber.trim();
  if (profilePhone != null && profilePhone.isNotEmpty) {
    return profilePhone;
  }

  final fallback = fallbackPhone?.trim();
  if (fallback != null && fallback.isNotEmpty) {
    return fallback;
  }

  return null;
}

/// Parses a stored phone into IntlPhoneField initial values.
ParsedPhoneForField parseProfilePhoneForField(String raw) {
  final String rawDigits = raw.replaceAll(RegExp(r'\D'), '');
  for (final MapEntry<String, String> market in _dialCodes.entries) {
    final String dial = market.value;
    if (dial != '251' &&
        rawDigits.startsWith(dial) &&
        rawDigits.length > dial.length + 6) {
      return ParsedPhoneForField(
        initialCountryCode: market.key,
        localNumber: rawDigits.substring(dial.length),
        completeNumber: rawDigits,
      );
    }
  }
  final normalized = PhoneUtils.normalizeLoginIdentifier(raw);
  if (normalized.startsWith('251') && normalized.length >= 12) {
    return ParsedPhoneForField(
      initialCountryCode: 'ET',
      localNumber: normalized.substring(3),
      completeNumber: normalized.substring(0, 12),
    );
  }

  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return ParsedPhoneForField(
    initialCountryCode: 'ET',
    localNumber: digits,
    completeNumber: normalized.isNotEmpty ? normalized : digits,
  );
}

const Map<String, String> _dialCodes = <String, String>{
  'ET': '251',
  'KE': '254',
  'SO': '252',
  'AE': '971',
};

/// Normalizes user-entered phone to digits-only paymentAccount (e.g. 251946514836).
///
/// [countryCode] makes local numbers country-aware: without it a Kenyan
/// "0712 345 678" would be read as Ethiopian (2517…).
String normalizePaymentAccount(String raw, {String? countryCode}) {
  final String? dial = countryCode == null ? null : _dialCodes[countryCode];
  if (dial != null && dial != '251') {
    String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(dial)) return digits;
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '$dial$digits';
  }
  return PhoneUtils.normalizeLoginIdentifier(raw);
}

/// Safaricom M-Pesa number for KasaPay: 2547XXXXXXXX or 2541XXXXXXXX.
bool isValidKenyanMpesaNumber(String? raw) {
  if (raw == null || raw.isEmpty) return false;
  return RegExp(r'^254(7|1)\d{8}$')
      .hasMatch(normalizePaymentAccount(raw, countryCode: 'KE'));
}

/// Whether [raw] is valid for payment initiation.
bool isValidPaymentAccount(String? raw) {
  if (raw == null || raw.isEmpty) return false;
  return PhoneUtils.isValidLoginIdentifier(normalizePaymentAccount(raw));
}

/// Telebirr phone normalization per payment guide (+251XXXXXXXXX).
String normalizeTelebirrPhone(String phone) {
  phone = phone.replaceAll(RegExp(r'[\s\-()]'), '');
  if (phone.startsWith('09')) return '+251${phone.substring(1)}';
  if (phone.startsWith('9') && phone.length == 9) return '+251$phone';
  return phone;
}
