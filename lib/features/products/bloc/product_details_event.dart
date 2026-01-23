import 'package:equatable/equatable.dart';

abstract class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();

  @override
  List<Object?> get props => [];
}

class ProductDetailsFetchRequested extends ProductDetailsEvent {
  const ProductDetailsFetchRequested({
    required this.productId,
    this.country,
    this.currency,
  });

  final String productId;
  final String? country;
  final String? currency;

  @override
  List<Object?> get props => [productId, country, currency];
}

class ProductDetailsVariantSelected extends ProductDetailsEvent {
  const ProductDetailsVariantSelected({
    required this.variantIndex,
  });

  final int variantIndex;

  @override
  List<Object?> get props => [variantIndex];
}

class ProductDetailsRefreshRequested extends ProductDetailsEvent {
  const ProductDetailsRefreshRequested({
    required this.productId,
    this.country,
    this.currency,
  });

  final String productId;
  final String? country;
  final String? currency;

  @override
  List<Object?> get props => [productId, country, currency];
}
