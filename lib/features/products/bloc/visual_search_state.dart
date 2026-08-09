part of 'visual_search_bloc.dart';

@immutable
sealed class VisualSearchState {}

class VisualSearchInitial extends VisualSearchState {}

class VisualSearchLoading extends VisualSearchState {}

class VisualSearchLoaded extends VisualSearchState {
  VisualSearchLoaded({
    required this.products,
    required this.message,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
    this.previewImageBase64,
    this.sourceUrl,
  });

  final List<Product> products;
  final String? message;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final String? previewImageBase64;
  final String? sourceUrl;

  VisualSearchLoaded copyWith({
    List<Product>? products,
    String? message,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    String? previewImageBase64,
    String? sourceUrl,
  }) {
    return VisualSearchLoaded(
      products: products ?? this.products,
      message: message ?? this.message,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      previewImageBase64: previewImageBase64 ?? this.previewImageBase64,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }
}

class VisualSearchError extends VisualSearchState {
  VisualSearchError(this.message, {this.localizationKey});

  final String message;
  final String? localizationKey;
}
