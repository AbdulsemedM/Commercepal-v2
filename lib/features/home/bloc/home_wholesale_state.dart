part of 'home_wholesale_bloc.dart';

@immutable
abstract class HomeWholesaleState {}

class HomeWholesaleInitial extends HomeWholesaleState {}

class HomeWholesaleLoading extends HomeWholesaleState {}

class HomeWholesaleLoaded extends HomeWholesaleState {
  HomeWholesaleLoaded({
    required this.sections,
    this.updatedAt,
  });

  final Map<String, List<Product>> sections;
  final DateTime? updatedAt;
}

class HomeWholesaleError extends HomeWholesaleState {
  HomeWholesaleError(this.message);

  final String message;
}
