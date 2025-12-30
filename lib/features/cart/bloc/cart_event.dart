part of 'cart_bloc.dart';

@immutable
sealed class CartEvent {}

final class CartLoadRequested extends CartEvent {}

final class CartAddItemRequested extends CartEvent {
  final String productId;
  final String configId;
  final int quantity;
  final String currency;
  final String country;

  CartAddItemRequested({
    required this.productId,
    required this.configId,
    required this.quantity,
    required this.currency,
    required this.country,
  });
}

final class CartUpdateItemRequested extends CartEvent {
  final int itemId;
  final int quantity;
  final String? replaceConfigId;

  CartUpdateItemRequested({
    required this.itemId,
    required this.quantity,
    this.replaceConfigId,
  });
}

final class CartDeleteItemRequested extends CartEvent {
  final int itemId;

  CartDeleteItemRequested({required this.itemId});
}

final class CartClearRequested extends CartEvent {}

final class CartRefreshRequested extends CartEvent {}

