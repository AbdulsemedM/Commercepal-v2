part of 'recently_viewed_bloc.dart';

@immutable
sealed class RecentlyViewedEvent {}

final class FetchRecentlyViewed extends RecentlyViewedEvent {}
