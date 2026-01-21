import 'package:equatable/equatable.dart';
import '../data/models/product_details.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded({
    required this.productDetails,
    this.selectedVariantIndex = 0,
  });

  final ProductDetails productDetails;
  final int selectedVariantIndex;

  @override
  List<Object?> get props => [productDetails, selectedVariantIndex];

  ProductDetailsLoaded copyWith({
    ProductDetails? productDetails,
    int? selectedVariantIndex,
  }) {
    return ProductDetailsLoaded(
      productDetails: productDetails ?? this.productDetails,
      selectedVariantIndex: selectedVariantIndex ?? this.selectedVariantIndex,
    );
  }
}

class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError({
    required this.message,
    this.errorCode,
  });

  final String message;
  final String? errorCode;

  @override
  List<Object?> get props => [message, errorCode];
}
