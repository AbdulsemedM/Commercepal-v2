part of 'home_discover_bloc.dart';

@immutable
abstract class HomeDiscoverState {}

class HomeDiscoverInitial extends HomeDiscoverState {}

class HomeDiscoverLoading extends HomeDiscoverState {}

class HomeDiscoverLoaded extends HomeDiscoverState {
  HomeDiscoverLoaded({
    required this.sections,
    this.updatedAt,
  });

  final Map<String, List<Product>> sections;
  final DateTime? updatedAt;
}

class HomeDiscoverError extends HomeDiscoverState {
  HomeDiscoverError(this.message);

  final String message;
}
