import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/orders_response.dart';

class OrdersDataProvider {
  OrdersDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _ordersEndpoint = '/api/v1/orders';

  Future<OrdersResponse> getOrders({
    required int customerId,
    String? stageCategory,
    String? searchQuery,
    String? dateFrom,
    String? dateTo,
    int? page,
    int? size,
    String? sort,
    String? direction,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'customerId': customerId,
      };

      if (stageCategory != null && stageCategory.isNotEmpty) {
        queryParameters['stageCategory'] = stageCategory;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['searchQuery'] = searchQuery;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParameters['dateFrom'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParameters['dateTo'] = dateTo;
      }
      if (page != null) {
        queryParameters['page'] = page;
      }
      if (size != null) {
        queryParameters['size'] = size;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParameters['sort'] = sort;
      }
      if (direction != null && direction.isNotEmpty) {
        queryParameters['direction'] = direction;
      }

      print('🟠 OrdersDataProvider: Making API call to $_ordersEndpoint');
      print('🟠 OrdersDataProvider: Query params: $queryParameters');
      AppLogger.i('Making API call to $_ordersEndpoint with query params: $queryParameters');
      final response = await _apiService.get<Map<String, dynamic>>(
        _ordersEndpoint,
        query: queryParameters,
      );

      print('🟠 OrdersDataProvider: API response received: ${response.statusCode}');
      AppLogger.i('API response received: ${response.statusCode}');
      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      // Extract data from nested response structure if present
      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data != null) {
        return OrdersResponse.fromJson(data);
      }

      // If no nested data, use response directly
      return OrdersResponse.fromJson(responseData);
    } on DioException catch (e) {
      AppLogger.e('Get orders failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get orders',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
