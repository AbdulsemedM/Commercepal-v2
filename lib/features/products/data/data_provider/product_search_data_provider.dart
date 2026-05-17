import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/product_search_request.dart';
import '../models/product_search_response.dart';

class ProductSearchDataProvider {
  ProductSearchDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _searchEndpoint = '/api/v1/products/search';

  Future<ProductSearchResponse> searchProducts(
    ProductSearchRequest request,
  ) async {
    try {
      final queryParams = request.toQueryParameters();
      final headers = request.toHeaders();

      final response = await _apiService.get<Map<String, dynamic>>(
        _searchEndpoint,
        query: queryParams,
        headers: headers.isNotEmpty ? headers : null,
      );

      if (response.data == null) {
        AppLogger.w(
          'Product search: response body was null; treating as empty results',
        );
        return ProductSearchResponse.empty(
          currentPage: request.page,
          size: request.size,
        );
      }

      final Object? raw = response.data;
      if (raw is! Map<String, dynamic>) {
        AppLogger.w(
          'Product search: unexpected response type ${raw.runtimeType}; treating as empty',
        );
        return ProductSearchResponse.empty(
          currentPage: request.page,
          size: request.size,
        );
      }

      try {
        return ProductSearchResponse.fromJson(raw);
      } catch (e, stack) {
        AppLogger.e(
          'Product search: JSON parse failed; treating as empty',
          error: e,
          stack: stack,
        );
        return ProductSearchResponse.empty(
          currentPage: request.page,
          size: request.size,
        );
      }
    } on DioException catch (e) {
      AppLogger.e('Product search failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during product search',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
