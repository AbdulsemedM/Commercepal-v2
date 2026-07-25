import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/core/auth/session_error.dart';
import 'package:commercepal/features/orders/data/models/orders_response.dart';
import 'package:commercepal/features/orders/data/repository/orders_repository.dart';
import 'package:commercepal/services/navigation_service.dart';
import 'package:commercepal/core/logging/app_logger.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({OrdersRepository? repository})
      : _repository = repository ?? OrdersRepository(),
        super(OrdersInitial()) {
    on<OrdersLoadRequested>(_onOrdersLoadRequested);
    on<OrdersRefreshRequested>(_onOrdersRefreshRequested);
  }

  final OrdersRepository _repository;

  Future<void> _onOrdersLoadRequested(
    OrdersLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    // print('🟢 OrdersBloc: OrdersLoadRequested event received');
    AppLogger.i('OrdersLoadRequested event received');
    emit(OrdersLoading());
    // print('🟢 OrdersBloc: Emitted OrdersLoading state');

    try {
      AppLogger.i('Fetching orders with customerId: ${event.customerId}, stageCategory: ${event.stageCategory}');
      final response = await _repository.getOrders(
        customerId: event.customerId,
        stageCategory: event.stageCategory,
        searchQuery: event.searchQuery,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        page: event.page,
        size: event.size,
        sort: event.sort,
        direction: event.direction,
      );

      AppLogger.i('Orders fetched successfully: ${response.content.length} orders');
      // print('🟢 OrdersBloc: Orders fetched successfully: ${response.content.length} orders');
      emit(OrdersLoaded(response));
      // print('🟢 OrdersBloc: Emitted OrdersLoaded state');
    } catch (e, stack) {
      AppLogger.e('Error loading orders', error: e, stack: stack);
      String errorMessage = 'Failed to load orders. Please try again.';

      if (e is Exception) {
        if (NavigationService.instance.handleSessionExpired(e) ||
            isUnauthorizedError(e)) {
          errorMessage = 'Session expired. Please login again.';
        } else {
          errorMessage = e.toString().contains('Customer ID is required')
              ? 'Please ensure you are logged in.'
              : errorMessage;
        }
      }

      // print('❌ OrdersBloc: Error occurred: $errorMessage');
      emit(OrdersError(errorMessage));
      // print('❌ OrdersBloc: Emitted OrdersError state');
    }
  }

  Future<void> _onOrdersRefreshRequested(
    OrdersRefreshRequested event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final response = await _repository.getOrders(
        customerId: event.customerId,
        stageCategory: event.stageCategory,
        searchQuery: event.searchQuery,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        page: event.page,
        size: event.size,
        sort: event.sort,
        direction: event.direction,
      );

      if (state is OrdersLoaded) {
        emit(OrdersLoaded(response));
      } else {
        emit(OrdersLoaded(response));
      }
    } catch (e) {
      // Don't emit error on refresh, just log it
      // The orders state remains unchanged
    }
  }
}
