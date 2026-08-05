/// Defensive JSON helpers for API payloads that may send ints as doubles,
/// strings as non-strings, or omit nested maps.
class JsonUtils {
  JsonUtils._();

  static int? asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static int asIntOr(dynamic value, int fallback) =>
      asInt(value) ?? fallback;

  static double? asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static double asDoubleOr(dynamic value, double fallback) =>
      asDouble(value) ?? fallback;

  static String asString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    return value.toString();
  }

  static bool asBool(dynamic value, [bool fallback = false]) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return fallback;
  }

  static Map<String, dynamic>? asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic val) => MapEntry(key.toString(), val),
      );
    }
    return null;
  }

  static List<dynamic>? asList(dynamic value) {
    if (value is List) return value;
    return null;
  }

  /// Coerces a JSON list (or single value) into a list of strings.
  static List<String> asStringList(dynamic value) {
    if (value == null) return const <String>[];
    if (value is String) {
      return value.trim().isEmpty ? const <String>[] : <String>[value];
    }
    final List<dynamic>? list = asList(value);
    if (list == null) return const <String>[];
    return list
        .where((dynamic item) => item != null)
        .map((dynamic item) => asString(item))
        .where((String s) => s.isNotEmpty)
        .toList();
  }
}
