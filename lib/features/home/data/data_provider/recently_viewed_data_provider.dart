import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import 'package:commercepal/features/products/data/models/product.dart';

class RecentlyViewedDataProvider {
  RecentlyViewedDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/products/recently-viewed';

  /// Fetches recently viewed products. Requires [country] and [currency] for
  /// X-Country and X-Currency headers. Authorization is added by AuthInterceptor.
  Future<List<Product>> getRecentlyViewed({
    required String country,
    required String currency,
  }) async {
    try {
      final headers = <String, String>{
        'X-Country': country,
        'X-Currency': currency,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        _endpoint,
        headers: headers,
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final data = response.data!;
      List<dynamic> rawList;

      if (data['data'] is List) {
        rawList = data['data'] as List<dynamic>;
      } else if (data['data'] is Map<String, dynamic>) {
        final inner = data['data'] as Map<String, dynamic>;
        rawList = inner['items'] as List<dynamic>? ??
            inner['content'] as List<dynamic>? ??
            inner['products'] as List<dynamic>? ??
            <dynamic>[];
      } else if (data['content'] is List) {
        rawList = data['content'] as List<dynamic>;
      } else if (data['products'] is List) {
        rawList = data['products'] as List<dynamic>;
      } else if (data['items'] is List) {
        rawList = data['items'] as List<dynamic>;
      } else {
        rawList = <dynamic>[];
      }

      return rawList
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.e(
        'Recently viewed fetch failed',
        error: e,
        stack: e.stackTrace,
      );
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error fetching recently viewed',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
