import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/forgot_password_request.dart';
import '../models/forgot_password_response.dart';

class ForgotPasswordDataProvider {
  ForgotPasswordDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/credentials/password/forgot';

  Future<ForgotPasswordResponse> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        _endpoint,
        data: request.toJson(),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      return ForgotPasswordResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Forgot password failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during forgot password',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
