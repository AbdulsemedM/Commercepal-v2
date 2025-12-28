import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/logout_response.dart';

class LogoutDataProvider {
  LogoutDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/auth/logout';

  Future<LogoutResponse> logout() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(_endpoint);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      return LogoutResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Logout failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during logout', error: e, stack: stack);
      rethrow;
    }
  }
}
