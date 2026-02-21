import '../data_provider/orders_data_provider.dart';
import '../models/order.dart';
import '../models/orders_response.dart';
import 'package:commercepal/core/logging/app_logger.dart';

class OrdersRepository {
  OrdersRepository({
    OrdersDataProvider? dataProvider,
  }) : _dataProvider = dataProvider ?? OrdersDataProvider();

  final OrdersDataProvider _dataProvider;

  /// Fetches orders from GET /api/v1/orders?page=0&size=20 (auth via Bearer token).
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
    AppLogger.i('OrdersRepository.getOrders - page: ${page ?? 0}, size: ${size ?? 20}');
    return await _dataProvider.getOrders(
      customerId: customerId,
      stageCategory: stageCategory,
      searchQuery: searchQuery,
      dateFrom: dateFrom,
      dateTo: dateTo,
      page: page ?? 0,
      size: size ?? 20,
      sort: sort,
      direction: direction,
    );
  }

  /// Fetches a single order by order number (for tracking / detail screen).
  Future<Order> getOrderByOrderNumber(String orderNumber) async {
    return await _dataProvider.getOrderByOrderNumber(orderNumber);
  }
}
