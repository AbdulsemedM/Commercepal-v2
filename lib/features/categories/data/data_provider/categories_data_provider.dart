import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/categories_response.dart';
import '../models/sub_categories_response.dart';

class CategoriesDataProvider {
  CategoriesDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _categoriesEndpoint = '/api/v1/categories';
  static const String _subCategoriesEndpoint =
      '/api/v1/categories/subcategories/category';

  Future<CategoriesResponse> getCategories() async {
    try {
      final headers = <String, String>{
        'accept': 'application/json',
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        _categoriesEndpoint,
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

      return CategoriesResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Get categories failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get categories',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<SubCategoriesResponse> getSubCategories(String categoryId) async {
    try {
      final headers = <String, String>{
        'accept': 'application/json',
      };

      final path = '$_subCategoriesEndpoint/$categoryId';

      final response = await _apiService.get<Map<String, dynamic>>(
        path,
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

      return SubCategoriesResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e(
        'Get subcategories failed for categoryId: $categoryId',
        error: e,
        stack: e.stackTrace,
      );
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get subcategories',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
