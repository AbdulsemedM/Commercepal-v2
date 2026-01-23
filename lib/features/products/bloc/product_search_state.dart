part of 'product_search_bloc.dart';

@immutable
sealed class ProductSearchState {}

final class ProductSearchInitial extends ProductSearchState {}

final class ProductSearchLoading extends ProductSearchState {}

final class ProductSearchLoadingMore extends ProductSearchState {
  final List<Product> products;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  ProductSearchLoadingMore({
    required this.products,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });
}

final class ProductSearchLoaded extends ProductSearchState {
  final List<Product> products;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool hasMore;

  ProductSearchLoaded({
    required this.products,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.hasMore,
  });
}

final class ProductSearchError extends ProductSearchState {
  final String message;

  ProductSearchError(this.message);
}
