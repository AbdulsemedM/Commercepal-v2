import 'app_update_check_result.dart';

/// Simple semver-like parsing and comparison (major.minor.patch).
class VersionParser {
  VersionParser._();

  /// Parses a version string (e.g. "4.1.3" or "4.1.3+138") into [major, minor, patch].
  /// Returns null if invalid; build suffix (+138) is ignored.
  static List<int>? parse(String version) {
    if (version.trim().isEmpty) return null;
    final String withoutBuild =
        version.split(RegExp(r'[+\-]')).first.trim();
    final parts = withoutBuild.split('.');
    if (parts.length < 3) return null;
    final major = int.tryParse(parts[0].trim());
    final minor = int.tryParse(parts[1].trim());
    final patch = int.tryParse(parts[2].trim());
    if (major == null || minor == null || patch == null) return null;
    return [major, minor, patch];
  }

  /// Returns: negative if current < latest, 0 if equal, positive if current > latest.
  /// Compares [major, minor, patch] in order.
  static int compare(String current, String latest) {
    final c = parse(current);
    final l = parse(latest);
    if (c == null || l == null) return 0; // treat as equal if unparseable
    for (int i = 0; i < 3; i++) {
      if (c[i] != l[i]) return c[i].compareTo(l[i]);
    }
    return 0;
  }

  /// True if current is strictly less than latest.
  static bool isCurrentLower(String current, String latest) {
    return compare(current, latest) < 0;
  }

  /// If current < latest: returns [AppUpdateType.optional] for patch-only bump,
  /// [AppUpdateType.mandatory] for minor or major bump.
  /// If current >= latest: returns [AppUpdateType.none].
  static AppUpdateType getUpdateType(String current, String latest) {
    final c = parse(current);
    final l = parse(latest);
    if (c == null || l == null) return AppUpdateType.none;
    if (compare(current, latest) >= 0) return AppUpdateType.none;

    // current < latest
    if (c[0] != l[0]) return AppUpdateType.mandatory; // major
    if (c[1] != l[1]) return AppUpdateType.mandatory; // minor
    return AppUpdateType.optional; // patch only
  }
}
