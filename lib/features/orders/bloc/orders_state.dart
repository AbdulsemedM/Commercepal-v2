part of 'orders_bloc.dart';

@immutable
sealed class OrdersState {}

final class OrdersInitial extends OrdersState {}

final class OrdersLoading extends OrdersState {}

final class OrdersLoaded extends OrdersState {
  final OrdersResponse response;

  /// True when these are only the orders placed on this phone without signing
  /// in (express checkout); the screen offers sign-in to see the full history.
  final bool guestOnly;

  OrdersLoaded(this.response, {this.guestOnly = false});
}

/// Not signed in and no phone-checkout orders to show.
final class OrdersSignInRequired extends OrdersState {}

final class OrdersError extends OrdersState {
  final String message;

  OrdersError(this.message);
}
