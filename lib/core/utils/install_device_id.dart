/// Resolves the install-scoped device identifier.
///
/// Prefers an already-persisted value, then a platform-supported ID, then a
/// one-time UUID fallback (which the caller must persist).
String resolveInstallDeviceId({
  required String? persisted,
  required String? platformId,
  required String fallbackUuid,
}) {
  final String? existing = persisted?.trim();
  if (existing != null && existing.isNotEmpty) {
    return existing;
  }
  final String? platform = platformId?.trim();
  if (platform != null && platform.isNotEmpty) {
    return platform;
  }
  return fallbackUuid;
}
