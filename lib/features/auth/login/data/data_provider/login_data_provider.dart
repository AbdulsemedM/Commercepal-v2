import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class LoginDataProvider {
  LoginDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/auth/login';

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

      // Extract data from nested response structure
      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;
      
      if (data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response structure: missing data field',
        );
      }

      return LoginResponse.fromJson(data);
    } on DioException catch (e) {
      AppLogger.e('Login failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during login', error: e, stack: stack);
      rethrow;
    }
  }

  static const String _otpRequestEndpoint = '/api/customer/auth/otp/request';
  static const String _otpVerifyEndpoint = '/api/customer/auth/otp/verify';

  /// Sends a one-time login code to [identifier] (phone → SMS, email → email).
  /// For a phone with no account, [firstName] creates one. Returns the masked
  /// destination, e.g. "********9409".
  Future<String> requestOtp({
    required String identifier,
    String? firstName,
    String? countryCode,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      _otpRequestEndpoint,
      data: <String, dynamic>{
        'identifier': identifier,
        if (firstName != null && firstName.trim().isNotEmpty)
          'firstName': firstName.trim(),
        if (countryCode != null && countryCode.isNotEmpty)
          'countryCode': countryCode,
      },
    );
    final data = response.data?['data'];
    if (data is Map<String, dynamic>) {
      final sentTo = data['sentTo'];
      if (sentTo is String && sentTo.isNotEmpty) return sentTo;
    }
    return identifier;
  }

  /// Verifies the code and returns the same tokens as password login.
  Future<LoginResponse> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      _otpVerifyEndpoint,
      data: <String, dynamic>{'identifier': identifier, 'code': code},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Invalid response structure: missing data field',
      );
    }
    return LoginResponse.fromJson(data);
  }
}
