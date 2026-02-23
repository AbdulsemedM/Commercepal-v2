/// Classifies payment methods by display/variant names for Waafi, Edahab, iPay.
/// Used to show method-specific phone UI and format paymentAccount.
enum PaymentMethodType {
  waafi,
  edahab,
  ipay,
  other,
}

/// Waafi prefix (without +) for building PhoneNumber sent to backend.
const Map<String, String> waafiPrefixMap = {
  'evc plus': '25261',
  'zaad': '25263',
  'sahal': '25290',
  'waafi djibouti': '25377',
  'waafi international': '97150',
};

const List<String> _waafiNames = [
  'evc plus',
  'zaad',
  'sahal',
  'waafi djibouti',
  'waafi international',
];

/// Returns the payment method type from category, item, and variant display names.
/// Checks all three so that e.g. Waafi with variant "EVC Plus" is detected.
PaymentMethodType getPaymentMethodType(
  String? categoryName,
  String? itemName,
  String? variantName,
) {
  final combined = [
    categoryName ?? '',
    itemName ?? '',
    variantName ?? '',
  ].join(' ').toLowerCase();

  if (combined.contains('edahab')) return PaymentMethodType.edahab;
  if (combined.contains('ipay')) return PaymentMethodType.ipay;
  for (final name in _waafiNames) {
    if (combined.contains(name)) return PaymentMethodType.waafi;
  }
  return PaymentMethodType.other;
}

/// Returns the Waafi phone prefix (without +) for the given display name(s),
/// or null if not a known Waafi variant.
String? getWaafiPrefix(String? categoryName, String? itemName, String? variantName) {
  final combined = [categoryName ?? '', itemName ?? '', variantName ?? ''].join(' ').toLowerCase();
  for (final entry in waafiPrefixMap.entries) {
    if (combined.contains(entry.key)) return entry.value;
  }
  return null;
}

/// True when the method requires method-specific phone (Waafi/Edahab/iPay).
bool requiresMethodSpecificPhone(PaymentMethodType type) {
  return type == PaymentMethodType.waafi ||
      type == PaymentMethodType.edahab ||
      type == PaymentMethodType.ipay;
}
