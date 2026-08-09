import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/product.dart';
import '../models/visual_search_result.dart';

class VisualSearchDataProvider {
  VisualSearchDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  static const String _imageSearchEndpoint = '/api/v1/products/image-search';
  static const String _searchByUrlEndpoint = '/api/v1/products/search-by-url';

  Future<VisualSearchResult> searchByImage({
    required String imageBase64,
    required Map<String, String> headers,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final Response<Map<String, dynamic>> response =
          await _apiService.post<Map<String, dynamic>>(
        _imageSearchEndpoint,
        data: <String, dynamic>{
          'imageBase64': imageBase64,
          'page': page,
          'size': size,
        },
        headers: headers,
      );
      return _parseResponse(response, page: page);
    } on DioException catch (e) {
      AppLogger.e('Image search failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<VisualSearchResult> searchByUrl({
    required String url,
    required Map<String, String> headers,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final Response<Map<String, dynamic>> response =
          await _apiService.post<Map<String, dynamic>>(
        _searchByUrlEndpoint,
        data: <String, dynamic>{
          'url': url,
          'page': page,
          'size': size,
        },
        headers: headers,
      );
      return _parseResponse(response, page: page);
    } on DioException catch (e) {
      AppLogger.e('URL search failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  VisualSearchResult _parseResponse(
    Response<Map<String, dynamic>> response, {
    required int page,
  }) {
    if (response.data == null) {
      return VisualSearchResult(
        products: const <Product>[],
        currentPage: page,
        hasNext: false,
      );
    }
    return VisualSearchResult.fromJson(response.data!, fallbackPage: page);
  }
}
