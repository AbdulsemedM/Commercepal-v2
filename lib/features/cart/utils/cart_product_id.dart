/// Normalizes catalog product ids to the customer-facing `cp-` prefix required
/// by the cart API.
String normalizeCartProductId(String productId) {
  final String trimmed = productId.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.toLowerCase().startsWith('cp-')) {
    return trimmed;
  }
  return 'cp-$trimmed';
}

/// The cart API expects `"0"` for the default/base variant; an empty string is
/// rejected with 400.
String apiCartConfigId(String configId) {
  final String trimmed = configId.trim();
  if (trimmed.isEmpty || trimmed == '0') return '0';
  return trimmed;
}
