import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  const EnvConfig({
    required this.baseUrl,
    this.connectTimeoutMs = 15000,
    this.receiveTimeoutMs = 20000,
  });

  final String baseUrl;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
}

class Env {
  static EnvConfig? _current;

  static EnvConfig get current {
    if (_current == null) {
      throw StateError(
        'Env not initialized. Call Env.initialize() before accessing Env.current',
      );
    }
    return _current!;
  }

  static Future<void> initialize() async {
    final baseUrl = dotenv.env['BASE_URL']?.trim() ?? '';
    const placeholderUrl = 'https://api.example.com';
    final isPlaceholderOrMissing =
        baseUrl.isEmpty || baseUrl == placeholderUrl;
    if (kReleaseMode && isPlaceholderOrMissing) {
      throw StateError(
        'BASE_URL must be set in .env for release builds. '
        'Do not use the placeholder $placeholderUrl in production.',
      );
    }
    final resolvedBaseUrl = baseUrl.isNotEmpty ? baseUrl : placeholderUrl;
    final Uri? baseUri = Uri.tryParse(resolvedBaseUrl);
    if (kReleaseMode &&
        (baseUri == null ||
            !baseUri.hasScheme ||
            baseUri.scheme.toLowerCase() != 'https')) {
      throw StateError(
        'BASE_URL must be an https:// URL in release builds. '
        'Cleartext HTTP is not allowed.',
      );
    }
    _current = EnvConfig(
      baseUrl: resolvedBaseUrl,
      connectTimeoutMs:
          int.tryParse(dotenv.env['CONNECT_TIMEOUT_MS'] ?? '15000') ?? 15000,
      receiveTimeoutMs:
          int.tryParse(dotenv.env['RECEIVE_TIMEOUT_MS'] ?? '20000') ?? 20000,
    );
  }
}
