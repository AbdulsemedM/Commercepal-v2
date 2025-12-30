part of 'cart_bloc.dart';

@immutable
sealed class CartState {}

final class CartInitial extends CartState {}

final class CartLoading extends CartState {}

final class CartLoaded extends CartState {
  final Cart cart;

  CartLoaded(this.cart);
}

final class CartError extends CartState {
  final String message;

  CartError(this.message);
}

final class CartItemAdded extends CartState {
  final Cart cart;

  CartItemAdded(this.cart);
}

final class CartItemUpdated extends CartState {
  final Cart cart;

  CartItemUpdated(this.cart);
}

final class CartItemDeleted extends CartState {
  final Cart cart;

  CartItemDeleted(this.cart);
}

final class CartCleared extends CartState {
  final ClearCartResponse response;

  CartCleared(this.response);
}

