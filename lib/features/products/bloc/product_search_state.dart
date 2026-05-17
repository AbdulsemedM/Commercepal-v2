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

  /// When set, UI may show a one-shot SnackBar then dispatch [ClearSearchNotice].
  final String? noticeKey;

  ProductSearchLoaded({
    required this.products,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.hasMore,
    this.noticeKey,
  });
}

final class ProductSearchError extends ProductSearchState {
  final String message;

  /// When set, [message] is ignored for display and this key is passed to [LocalizationService.t].
  final String? localizationKey;

  ProductSearchError(this.message, {this.localizationKey});
}
