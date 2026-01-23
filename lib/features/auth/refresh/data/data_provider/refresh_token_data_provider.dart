import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/core/config/env.dart';
import 'package:commercepal/core/network/interceptors/logging_interceptor.dart';
import '../models/refresh_token_request.dart';
import '../models/refresh_token_response.dart';

class RefreshTokenDataProvider {
  RefreshTokenDataProvider({Dio? dio}) : _dio = dio ?? _createRefreshDio();

  final Dio _dio;
  static const String _endpoint = '/api/v1/auth/refresh';

  // Create a separate Dio instance for refresh requests to avoid circular dependency
  static Dio _createRefreshDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.current.baseUrl,
        connectTimeout: Duration(milliseconds: Env.current.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: Env.current.receiveTimeoutMs),
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    // Add logging interceptor for all refresh token requests
    dio.interceptors.add(LoggingInterceptor());
    return dio;
  }

  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
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
