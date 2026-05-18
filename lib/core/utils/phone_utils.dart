/// Normalizes phone numbers for API identifiers (digits only, no '+').
class PhoneUtils {
  PhoneUtils._();

  /// Produces API login identifier, e.g. `251946514836`.
  static String normalizeLoginIdentifier(String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return digits;

    if (digits.length >= 12 && digits.startsWith('251')) {
      return digits.substring(0, 12);
    }
    if (digits.length == 10 && digits.startsWith('0')) {
      return '251${digits.substring(1)}';
    }
    if (digits.length == 9 && !digits.startsWith('0')) {
      return '251$digits';
    }
    if (digits.length >= 9 && digits.startsWith('251')) {
      return digits.length > 12 ? digits.substring(0, 12) : digits;
    }
    if (digits.length >= 9) {
      return digits;
    }
    return digits;
  }

  /// Whether [raw] looks like a phone identifier (not an email).
  static bool looksLikePhone(String raw) => !raw.contains('@');

  /// Minimum length for a normalized international login identifier.
  static bool isValidLoginIdentifier(String normalized) =>
      normalized.length >= 10 && RegExp(r'^\d+$').hasMatch(normalized);

}
