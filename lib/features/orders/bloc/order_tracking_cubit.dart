import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/features/orders/data/models/order.dart';
import 'package:commercepal/features/orders/data/repository/orders_repository.dart';

part 'order_tracking_state.dart';

class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  OrderTrackingCubit({OrdersRepository? repository})
    : _repository = repository ?? OrdersRepository(),
      super(OrderTrackingInitial());

  final OrdersRepository _repository;

  void setOrder(Order order) {
    emit(OrderTrackingLoaded(order));
  }

  Future<void> loadOrderByOrderNumber(String orderNumber) async {
    emit(OrderTrackingLoading());
    try {
      final order = await _repository.getOrderByOrderNumber(orderNumber);
      emit(OrderTrackingLoaded(order));
    } catch (e) {
      emit(
        OrderTrackingError(
          e is Exception ? e.toString() : 'Failed to load order',
        ),
      );
    }
  }
}
