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
  const OrderTrackingLoaded(this.order, {this.fromCache = false});

  final Order order;

  /// True when [order] was restored from on-device cache (e.g. offline).
  final bool fromCache;
}

final class OrderTrackingError extends OrderTrackingState {
  const OrderTrackingError(this.message);
  final String message;
}
