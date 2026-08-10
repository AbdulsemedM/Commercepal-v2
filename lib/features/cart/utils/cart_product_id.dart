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
