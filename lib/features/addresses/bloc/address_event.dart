part of 'address_bloc.dart';

@immutable
sealed class AddressEvent {}

final class AddressLoadRequested extends AddressEvent {}

final class AddressAddRequested extends AddressEvent {
  final AddAddressRequest request;

  AddressAddRequested({required this.request});
}

final class AddressUpdateRequested extends AddressEvent {
  final int addressId;
  final UpdateAddressRequest request;

  AddressUpdateRequested({required this.addressId, required this.request});
}

final class AddressSetDefaultRequested extends AddressEvent {
  final int addressId;

  AddressSetDefaultRequested({required this.addressId});
}

final class AddressDeleteRequested extends AddressEvent {
  final int addressId;

  AddressDeleteRequested({required this.addressId});
}

final class AddressRefreshRequested extends AddressEvent {}
