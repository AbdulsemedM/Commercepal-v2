part of 'order_tracking_cubit.dart';

sealed class OrderTrackingState {
  const OrderTrackingState();
}

final class OrderTrackingInitial extends OrderTrackingState {
  const OrderTrackingInitial();
}

final class OrderTrackingLoading extends OrderTrackingState {
  const OrderTrackingLoading();
}

final class OrderTrackingLoaded extends OrderTrackingState {
  const OrderTrackingLoaded(this.order);
  final Order order;
}

final class OrderTrackingError extends OrderTrackingState {
  const OrderTrackingError(this.message);
  final String message;
}
