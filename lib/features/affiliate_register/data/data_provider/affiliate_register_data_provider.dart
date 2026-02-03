import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/affiliate_register_request_dto.dart';

class AffiliateRegisterDataProvider {
  AffiliateRegisterDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/affiliates/register';

  Future<void> register(AffiliateRegisterRequestDto request) async {
    try {
      await _apiService.post<Map<String, dynamic>>(
        _endpoint,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      AppLogger.e(
        'Affiliate register failed',
        error: e,
        stack: e.stackTrace,
      );
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during affiliate register',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
