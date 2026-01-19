part of 'product_search_bloc.dart';

@immutable
sealed class ProductSearchEvent {}

final class SearchProducts extends ProductSearchEvent {
  final ProductSearchRequest request;

  SearchProducts({required this.request});
}

final class LoadMoreProducts extends ProductSearchEvent {}

final class ApplyFilters extends ProductSearchEvent {
  final String? categoryId;
  final String? provider;
  final String? orderBy;
  final String? brandId;
  final bool? isTmall;
  final bool? useOptimalFrameSize;
  final int? maxVolume;
  final int? minVolume;
  final double? minPrice;
  final double? maxPrice;

  ApplyFilters({
    this.categoryId,
    this.provider,
    this.orderBy,
    this.brandId,
    this.isTmall,
    this.useOptimalFrameSize,
    this.maxVolume,
    this.minVolume,
    this.minPrice,
    this.maxPrice,
  });
}

final class ResetSearch extends ProductSearchEvent {}
