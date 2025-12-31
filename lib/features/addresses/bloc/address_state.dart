part of 'address_bloc.dart';

@immutable
sealed class AddressState {}

final class AddressInitial extends AddressState {}

final class AddressLoading extends AddressState {}

final class AddressLoaded extends AddressState {
  final List<Address> addresses;

  AddressLoaded(this.addresses);
}

final class AddressError extends AddressState {
  final String message;

  AddressError(this.message);
}

final class AddressAdded extends AddressState {
  final Address address;

  AddressAdded(this.address);
}

final class AddressUpdated extends AddressState {
  final Address address;

  AddressUpdated(this.address);
}

final class AddressSetDefault extends AddressState {
  final Address address;

  AddressSetDefault(this.address);
}

final class AddressDeleted extends AddressState {
  final DeleteAddressResponse response;

  AddressDeleted(this.response);
}
