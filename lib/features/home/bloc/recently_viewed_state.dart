part of 'recently_viewed_bloc.dart';

@immutable
sealed class RecentlyViewedState {}

final class RecentlyViewedInitial extends RecentlyViewedState {}

final class RecentlyViewedLoading extends RecentlyViewedState {}

final class RecentlyViewedLoaded extends RecentlyViewedState {
  final List<Product> products;

  RecentlyViewedLoaded({required this.products});
}

final class RecentlyViewedError extends RecentlyViewedState {
  final String message;

  RecentlyViewedError(this.message);
}
