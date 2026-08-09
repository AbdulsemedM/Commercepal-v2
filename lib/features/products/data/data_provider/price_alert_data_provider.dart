import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';

class PriceAlertDataProvider {
  PriceAlertDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<void> setPriceAlert({
    required String productId,
    required double targetPrice,
  }) async {
    try {
      await _apiService.post<Map<String, dynamic>>(
        '/api/v1/products/$productId/price-alert',
        data: <String, dynamic>{'targetPrice': targetPrice},
      );
    } on DioException catch (e) {
      AppLogger.e('Set price alert failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<void> removePriceAlert({required String productId}) async {
    try {
      await _apiService.delete<Map<String, dynamic>>(
        '/api/v1/products/$productId/price-alert',
      );
    } on DioException catch (e) {
      AppLogger.e('Remove price alert failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }
}
