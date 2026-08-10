import 'package:dio/dio.dart';

/// Maps checkout API errors to user-facing messages (guide §11).
String mapCheckoutApiError(
  Object error, {
  required String defaultMessage,
  required String sessionExpiredMessage,
  required String invalidOrderDataMessage,
  required String serverErrorMessage,
  required String serviceUnavailableMessage,
  required String conflictMessage,
}) {
  if (error is DioException) {
    final int? status = error.response?.statusCode;
    final dynamic data = error.response?.data;
    String? apiMessage;
    String? errorCode;

    if (data is Map<String, dynamic>) {
      apiMessage = data['message'] as String?;
      errorCode = data['errorCode'] as String?;
    }

    if (status == 401) return sessionExpiredMessage;
    if (status == 503) return serviceUnavailableMessage;
    if (status == 409) {
      return apiMessage?.isNotEmpty == true ? apiMessage! : conflictMessage;
    }
    if (status == 400) {
      if (errorCode == 'VALIDATION_ERROR' && apiMessage?.isNotEmpty == true) {
        return apiMessage!;
      }
      if (apiMessage?.isNotEmpty == true) return apiMessage!;
      return invalidOrderDataMessage;
    }
    if (status != null && status >= 500) return serverErrorMessage;
    if (apiMessage != null && apiMessage.isNotEmpty) return apiMessage;
  }

  return defaultMessage;
}
