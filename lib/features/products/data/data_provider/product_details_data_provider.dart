import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/product_details_response.dart';

class ProductDetailsDataProvider {
  ProductDetailsDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _detailsEndpoint = '/api/v1/products';

  Future<ProductDetailsResponse> getProductDetails(
    String itemId, {
    String? country,
    String? currency,
  }) async {
    try {
      final path = '$_detailsEndpoint/$itemId';
      final headers = <String, String>{};

      if (country != null && country.isNotEmpty) {
        headers['X-Country'] = country;
      }

      if (currency != null && currency.isNotEmpty) {
        headers['X-Currency'] = currency;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        path,
        headers: headers.isNotEmpty ? headers : null,
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      return ProductDetailsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e(
        'Product details fetch failed for itemId: $itemId',
        error: e,
        stack: e.stackTrace,
      );
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during product details fetch',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
