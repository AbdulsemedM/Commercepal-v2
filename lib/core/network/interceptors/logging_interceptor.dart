import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../logging/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  final bool requestHeader;
  final bool requestBody;
  final bool responseHeader;
  final bool responseBody;
  final bool errorResponse;

  LoggingInterceptor({
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = true,
    this.responseBody = true,
    this.errorResponse = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final StringBuffer logBuffer = StringBuffer();
      logBuffer.writeln('┌─────────────────────────────────────────────────');
      logBuffer.writeln('│ 📤 REQUEST');
      logBuffer.writeln('├─────────────────────────────────────────────────');
      logBuffer.writeln('│ ${options.method} ${options.uri}');

      if (requestHeader && options.headers.isNotEmpty) {
        logBuffer.writeln('│');
        logBuffer.writeln('│ Headers:');
        final safeHeaders = _sanitizeHeaders(options.headers);
        safeHeaders.forEach((key, value) {
          logBuffer.writeln('│   $key: $value');
        });
      }

      if (requestBody && options.data != null) {
        final isAuth = _isAuthPath(options.uri.path);
        logBuffer.writeln('│');
        logBuffer.writeln('│ Body:');
        if (isAuth) {
          logBuffer.writeln('│   [REDACTED - auth endpoint]');
        } else {
          final bodyString = _formatData(options.data);
          bodyString.split('\n').forEach((line) {
            logBuffer.writeln('│   $line');
          });
        }
      }

      if (options.queryParameters.isNotEmpty) {
        logBuffer.writeln('│');
        logBuffer.writeln('│ Query Parameters:');
        options.queryParameters.forEach((key, value) {
          logBuffer.writeln('│   $key: $value');
        });
      }

      logBuffer.writeln('└─────────────────────────────────────────────────');
      // Log directly to console for better visibility
      if (kDebugMode) {
        _logFullMessage(logBuffer.toString(), 'API_REQUEST');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final StringBuffer logBuffer = StringBuffer();
      logBuffer.writeln('┌─────────────────────────────────────────────────');
      logBuffer.writeln('│ 📥 RESPONSE');
      logBuffer.writeln('├─────────────────────────────────────────────────');
      logBuffer.writeln(
        '│ ${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      logBuffer.writeln('│ Status Code: ${response.statusCode}');
      logBuffer.writeln('│ Status Message: ${response.statusMessage ?? 'N/A'}');

      if (responseHeader && response.headers.map.isNotEmpty) {
        logBuffer.writeln('│');
        logBuffer.writeln('│ Headers:');
        response.headers.map.forEach((key, values) {
          logBuffer.writeln('│   $key: ${values.join(', ')}');
        });
      }

      if (responseBody && response.data != null) {
        final isAuth = _isAuthPath(response.requestOptions.uri.path);
        logBuffer.writeln('│');
        logBuffer.writeln('│ Body:');
        if (isAuth) {
          logBuffer.writeln('│   [REDACTED - auth endpoint]');
        } else {
          final bodyString = _formatData(response.data);
          bodyString.split('\n').forEach((line) {
            logBuffer.writeln('│   $line');
          });
        }
      }

      logBuffer.writeln('└─────────────────────────────────────────────────');
      // Log directly to console for better visibility
      if (kDebugMode) {
        _logFullMessage(logBuffer.toString(), 'API_RESPONSE');
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final StringBuffer logBuffer = StringBuffer();
      logBuffer.writeln('┌─────────────────────────────────────────────────');
      logBuffer.writeln('│ ❌ ERROR');
      logBuffer.writeln('├─────────────────────────────────────────────────');
      logBuffer.writeln(
        '│ ${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      logBuffer.writeln('│ Error Type: ${err.type}');
      logBuffer.writeln('│ Error Message: ${err.message}');

      if (err.response != null) {
        logBuffer.writeln('│ Status Code: ${err.response?.statusCode}');
        logBuffer.writeln(
          '│ Status Message: ${err.response?.statusMessage ?? 'N/A'}',
        );

        if (errorResponse && err.response?.data != null) {
          logBuffer.writeln('│');
          logBuffer.writeln('│ Error Response:');
          final bodyString = _formatData(err.response?.data);
          bodyString.split('\n').forEach((line) {
            logBuffer.writeln('│   $line');
          });
        }
      } else {
        logBuffer.writeln('│ No response received');
      }

      logBuffer.writeln('└─────────────────────────────────────────────────');
      _logFullMessage(logBuffer.toString(), 'API_ERROR');
      AppLogger.e(
        'API Error: ${err.requestOptions.method} ${err.requestOptions.uri}',
        error: err,
        stack: err.stackTrace,
      );
    }
    // Release: do not log URIs/messages (commented AppLogger.e is a no-op today;
    // keep this branch empty so re-enabling AppLogger.e cannot leak in prod).
    super.onError(err, handler);
  }

  String _formatData(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is String) {
        // Try to parse as JSON for pretty printing
        try {
          final jsonData = jsonDecode(data);
          return const JsonEncoder.withIndent('  ').convert(jsonData);
        } catch (_) {
          return data;
        }
      } else if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return data.toString();
    }
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    // Mask sensitive headers
    final sensitiveHeaders = ['authorization', 'cookie', 'x-api-key'];
    sanitized.forEach((key, value) {
      if (sensitiveHeaders.contains(key.toLowerCase())) {
        if (value is String && value.length > 10) {
          sanitized[key] = '${value.substring(0, 10)}...';
        }
      }
    });
    return sanitized;
  }

  static bool _isAuthPath(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/oauth2');
  }

  /// Logs a message in chunks to avoid truncation
  /// Dart's print() and dev.log() have limitations on string length
  void _logFullMessage(String message, String name) {
    const int chunkSize = 800; // Safe chunk size for most consoles

    if (message.length <= chunkSize) {
      // Message is short enough, log it normally
      print(message);
      dev.log(message, name: name);
      return;
    }

    // Split message into chunks
    final lines = message.split('\n');
    final chunks = <String>[];
    StringBuffer currentChunk = StringBuffer();

    for (final line in lines) {
      // If adding this line would exceed chunk size, save current chunk and start new one
      if (currentChunk.length + line.length + 1 > chunkSize &&
          currentChunk.length > 0) {
        chunks.add(currentChunk.toString());
        currentChunk = StringBuffer();
      }
      currentChunk.writeln(line);
    }

    // Add the last chunk if it has content
    if (currentChunk.length > 0) {
      chunks.add(currentChunk.toString());
    }

    // Log each chunk separately
    for (int i = 0; i < chunks.length; i++) {
      final chunkHeader = chunks.length > 1
          ? '[$name - Part ${i + 1}/${chunks.length}]'
          : name;
      print(chunks[i]);
      dev.log(chunks[i], name: chunkHeader);
    }
  }
}
