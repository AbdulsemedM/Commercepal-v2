import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/refresh_token_request.dart';
import '../models/refresh_token_response.dart';

class RefreshTokenDataProvider {
  RefreshTokenDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/auth/refresh';

  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request) async {
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

      return RefreshTokenResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Refresh token failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during refresh token',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
