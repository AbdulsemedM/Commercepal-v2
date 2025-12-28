import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';

class ProfileDataProvider {
  ProfileDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/customers/profile';

  Future<ProfileResponse> getProfile() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(_endpoint);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      return ProfileResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Get profile failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get profile',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<ProfileResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/v1/customers/me',
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

      return ProfileResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Update profile failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during update profile',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
