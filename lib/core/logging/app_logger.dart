import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(String message, {Object? data}) {
    if (kDebugMode) _log('DEBUG', message, data);
  }

  static void i(String message, {Object? data}) {
    if (kDebugMode) _log('INFO', message, data);
  }

  static void w(String message, {Object? data}) {
    if (kDebugMode) _log('WARN', message, data);
  }

  static void e(
    String message, {
    Object? error,
    StackTrace? stack,
    Object? data,
  }) {
    // Commented out for release / MobSF — uncomment for local debugging.
    // _log('ERROR', message, data, error: error, stack: stack);
  }

  static void _log(
    String level,
    String message,
    Object? data, {
    Object? error,
    StackTrace? stack,
  }) {
    final StringBuffer sb = StringBuffer('[$level] $message');
    if (data != null) {
      try {
        final String json = const JsonEncoder.withIndent('  ').convert(data);
        sb.write('\n$data: $json');
      } catch (_) {
        sb.write('\n$data');
      }
    }
    if (error != null) sb.write('\nerror: $error');
    if (stack != null) sb.write('\nstack: $stack');
    dev.log(sb.toString(), name: 'App');
  }
}
