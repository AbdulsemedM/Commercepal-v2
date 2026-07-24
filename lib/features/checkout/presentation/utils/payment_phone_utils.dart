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

/// Normalizes user-entered phone to digits-only paymentAccount (e.g. 251946514836).
String normalizePaymentAccount(String raw) =>
    PhoneUtils.normalizeLoginIdentifier(raw);

/// Whether [raw] is valid for payment initiation.
bool isValidPaymentAccount(String? raw) {
  if (raw == null || raw.isEmpty) return false;
  return PhoneUtils.isValidLoginIdentifier(normalizePaymentAccount(raw));
}
