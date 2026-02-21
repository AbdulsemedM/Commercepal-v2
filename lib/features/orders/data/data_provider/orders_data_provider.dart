import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/order.dart';
import '../models/orders_response.dart';

class OrdersDataProvider {
  OrdersDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _ordersEndpoint = '/api/v1/orders';

  Future<OrdersResponse> getOrders({
    int? customerId,
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
        'page': page ?? 0,
        'size': size ?? 20,
      };
      if (customerId != null) {
        queryParameters['customerId'] = customerId;
      }
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
      if (sort != null && sort.isNotEmpty) {
        queryParameters['sort'] = sort;
      }
      if (direction != null && direction.isNotEmpty) {
        queryParameters['direction'] = direction;
      }

      print('🟠 OrdersDataProvider: Making API call to $_ordersEndpoint');
      print('🟠 OrdersDataProvider: Query params: $queryParameters');
      AppLogger.i(
        'Making API call to $_ordersEndpoint with query params: $queryParameters',
      );
      final response = await _apiService.get<Map<String, dynamic>>(
        _ordersEndpoint,
        query: queryParameters,
      );

      print(
        '🟠 OrdersDataProvider: API response received: ${response.statusCode}',
      );
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
        // API returns { "pagination": { page, size, totalElements, totalPages, hasNext, hasPrevious }, "items": [...] }
        final pagination = data['pagination'] as Map<String, dynamic>?;
        final itemsJson = data['items'] as List<dynamic>? ?? data['content'] as List<dynamic>? ?? [];
        final pageNum = pagination?['page'] as int? ?? 0;
        final pageSize = pagination?['size'] as int? ?? 20;
        final totalElements = pagination?['totalElements'] as int? ?? itemsJson.length;
        final totalPages = pagination?['totalPages'] as int? ?? (totalElements > 0 ? 1 : 0);
        final normalized = <String, dynamic>{
          'content': itemsJson,
          'totalPages': totalPages,
          'totalElements': totalElements,
          'first': pageNum == 0,
          'last': pagination?['hasNext'] != true,
          'size': pageSize,
          'number': pageNum,
          'numberOfElements': itemsJson.length,
          'empty': itemsJson.isEmpty,
          'sort': <String, dynamic>{'empty': true, 'unsorted': true, 'sorted': false},
          'pageable': <String, dynamic>{
            'offset': pageNum * pageSize,
            'sort': <String, dynamic>{'empty': true, 'unsorted': true, 'sorted': false},
            'unpaged': false,
            'pageSize': pageSize,
            'paged': true,
            'pageNumber': pageNum,
          },
        };
        return OrdersResponse.fromJson(normalized);
      }

      // If no nested data, use response directly
      return OrdersResponse.fromJson(responseData);
    } on DioException catch (e) {
      AppLogger.e('Get orders failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during get orders', error: e, stack: stack);
      rethrow;
    }
  }

  /// Fetches a single order by order number (for order tracking / detail).
  /// Backend should expose GET /api/v1/orders/{orderNumber} or equivalent.
  Future<Order> getOrderByOrderNumber(String orderNumber) async {
    try {
      final uri = '$_ordersEndpoint/$orderNumber';
      AppLogger.i('Fetching order by number: $uri');
      final response = await _apiService.get<Map<String, dynamic>>(uri);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;
      final orderJson = data ?? responseData;
      return Order.fromJson(orderJson);
    } on DioException catch (e) {
      AppLogger.e('Get order by number failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get order by number',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
