part of 'orders_bloc.dart';

@immutable
sealed class OrdersState {}

final class OrdersInitial extends OrdersState {}

final class OrdersLoading extends OrdersState {}

final class OrdersLoaded extends OrdersState {
  final OrdersResponse response;

  OrdersLoaded(this.response);
}

final class OrdersError extends OrdersState {
  final String message;

  OrdersError(this.message);
}
