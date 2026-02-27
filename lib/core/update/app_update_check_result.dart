/// Result of comparing current app version with Remote Config latest version.
enum AppUpdateType {
  /// No update needed (current >= latest).
  none,

  /// Only patch changed (e.g. 4.1.3 → 4.1.4): optional update.
  optional,

  /// Minor or major changed (e.g. 4.1.3 → 4.2.0 or 5.0.0): mandatory update.
  mandatory,
}

/// Result of the startup version check.
class AppUpdateCheckResult {
  const AppUpdateCheckResult({
    required this.updateType,
    required this.currentVersion,
    required this.latestVersion,
    required this.storeUrl,
  });

  final AppUpdateType updateType;
  final String currentVersion;
  final String latestVersion;
  final String storeUrl;

  bool get hasUpdate =>
      updateType == AppUpdateType.optional ||
      updateType == AppUpdateType.mandatory;

  bool get isMandatory => updateType == AppUpdateType.mandatory;
}
