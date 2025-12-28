import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/signup_request.dart';
import '../models/signup_response.dart';

class SignupDataProvider {
  SignupDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/customers/register';

  Future<SignupResponse> signup(SignupRequest request) async {
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

      return SignupResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Signup failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during signup', error: e, stack: stack);
      rethrow;
    }
  }
}
