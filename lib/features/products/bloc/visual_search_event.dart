part of 'visual_search_bloc.dart';

@immutable
sealed class VisualSearchEvent {}

class VisualSearchReset extends VisualSearchEvent {}

class VisualSearchByImageRequested extends VisualSearchEvent {
  VisualSearchByImageRequested(this.imageBase64);

  final String imageBase64;
}

class VisualSearchByUrlRequested extends VisualSearchEvent {
  VisualSearchByUrlRequested(this.url);

  final String url;
}

class VisualSearchLoadMoreRequested extends VisualSearchEvent {}
