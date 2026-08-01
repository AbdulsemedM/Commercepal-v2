import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/fcm_register_request.dart';
import '../models/fcm_unregister_request.dart';

class FcmDataProvider {
  FcmDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _registerEndpoint = '/api/v1/fcm/token/register';
  static const String _unregisterEndpoint = '/api/v1/fcm/token/unregister';

  Future<void> register(FcmRegisterRequest request) async {
    try {
      await _apiService.post<Map<String, dynamic>>(
        _registerEndpoint,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      AppLogger.e('FCM register failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during FCM register', error: e, stack: stack);
      rethrow;
    }
  }

  Future<void> unregister(FcmUnregisterRequest request) async {
    try {
      await _apiService.delete<Map<String, dynamic>>(
        _unregisterEndpoint,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      AppLogger.e('FCM unregister failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during FCM unregister',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
