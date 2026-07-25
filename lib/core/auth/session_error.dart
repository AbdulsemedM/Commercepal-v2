import 'package:dio/dio.dart';

import 'package:commercepal/core/network/interceptors/auth_interceptor.dart';

/// True when the server rejected the caller's credentials.
///
/// Uses HTTP status and structured response bodies only — never substring-matches
/// on [Object.toString], which can false-positive on product ids, prices, etc.
bool isUnauthorizedError(Object? error) {
  if (error == null) return false;
  if (error is SessionRejected) return true;

  if (error is DioException) {
    final int? status = error.response?.statusCode;
    if (status == 401 || status == 403) return true;

    final Object? data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final String message = (data['message'] as String? ??
              data['error'] as String? ??
              '')
          .toLowerCase();
      if (message.contains('session expired') ||
          message.contains('token expired') ||
          message.contains('jwt expired') ||
          message == 'unauthorized') {
        return true;
      }
    }

    return false;
  }

  return false;
}
