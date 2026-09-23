import 'version_parser.dart';

/// Validation and sanitization for Firebase Remote Config update-related values.
abstract final class RemoteConfigValueValidators {
  RemoteConfigValueValidators._();

  static final RegExp _htmlTag = RegExp(r'<[^>]*>');
  static final RegExp _controlChars = RegExp(r'[\x00-\x1F\x7F]');
  static final RegExp _whitespaceCollapse = RegExp(r'\s+');

  /// Returns true if [url] is an allowlisted store listing URL for the platform.
  static bool isAllowedStoreUrl(String url, {required bool android}) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.isAbsolute) return false;

    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();

    if (android) {
      if (scheme == 'https' && host == 'play.google.com') return true;
      // market://details?id=com.example.app — host is typically "details"
      if (scheme == 'market') {
        final path = uri.path.toLowerCase();
        return host == 'details' ||
            path == 'details' ||
            path == '/details' ||
            path.startsWith('/details/');
      }
      return false;
    }

    if (scheme == 'https' &&
        (host == 'apps.apple.com' || host == 'itunes.apple.com')) {
      return true;
    }
    return false;
  }

  /// True when [version] parses as major.minor.patch (build suffix allowed).
  static bool isValidAppVersion(String version) {
    return VersionParser.parse(version) != null;
  }

  /// Strips HTML-like tags and control characters; collapses whitespace; truncates.
  static String sanitizeDisplayMessage(String raw, {int maxLength = 200}) {
    if (maxLength < 0) maxLength = 0;
    var text = raw.replaceAll(_htmlTag, '');
    text = text.replaceAll(_controlChars, '');
    text = text.replaceAll(_whitespaceCollapse, ' ').trim();
    if (text.length > maxLength) {
      text = text.substring(0, maxLength).trim();
    }
    return text;
  }
}
