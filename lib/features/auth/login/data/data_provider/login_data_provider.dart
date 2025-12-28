import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class LoginDataProvider {
  LoginDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/auth/login';

  Future<LoginResponse> login(LoginRequest request) async {
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

      return LoginResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Login failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during login', error: e, stack: stack);
      rethrow;
    }
  }
}
