import 'package:commercepal/core/auth/express_checkout.dart';
import 'package:commercepal/services/auth_service.dart';

import '../data_provider/address_data_provider.dart';
import '../models/address.dart';
import '../models/add_address_request.dart';
import '../models/update_address_request.dart';
import '../models/delete_address_response.dart';

class AddressRepository {
  AddressRepository({AddressDataProvider? dataProvider})
    : _dataProvider = dataProvider ?? AddressDataProvider();

  final AddressDataProvider _dataProvider;

  /// Phone checkout without a code: the checkout-only token can create an
  /// address but never list or edit the account's saved addresses, so this
  /// session's addresses are kept on the device instead.
  bool get _express =>
      !AuthService().isLoggedIn && ExpressCheckout.instance.isActive;

  Future<Address> addAddress(AddAddressRequest request) async {
    final Address address = await _dataProvider.addAddress(request);
    if (_express) {
      await ExpressCheckout.instance.rememberAddress(address.toJson());
    }
    return address;
  }

  Future<List<Address>> getAllAddresses() async {
    if (_express) {
      await ExpressCheckout.instance.ensureLoaded();
      return ExpressCheckout.instance.sessionAddresses
          .map(Address.fromJson)
          .toList();
    }
    return await _dataProvider.getAllAddresses();
  }

  Future<Address> updateAddress(
    int addressId,
    UpdateAddressRequest request,
  ) async {
    if (_express) {
      // Editing = saving a corrected copy for this order.
      final Address created = await addAddress(
        AddAddressRequest(
          receiverName: request.receiverName,
          phoneNumber: request.phoneNumber,
          countryCode: request.countryCode,
          state: request.state,
          city: request.city,
          district: request.district,
          street: request.street,
          houseNumber: request.houseNumber,
          landmark: request.landmark,
          addressLine1: request.addressLine1,
          addressLine2: request.addressLine2,
          latitude: request.latitude,
          longitude: request.longitude,
          addressSource: request.addressSource,
          isDefault: request.isDefault,
        ),
      );
      await ExpressCheckout.instance.forgetAddress(addressId);
      return created;
    }
    return await _dataProvider.updateAddress(addressId, request);
  }

  Future<Address> setDefaultAddress(int addressId) async {
    if (_express) {
      final List<Address> all = await getAllAddresses();
      return all.firstWhere(
        (Address a) => a.id == addressId,
        orElse: () => all.first,
      );
    }
    return await _dataProvider.setDefaultAddress(addressId);
  }

  Future<DeleteAddressResponse> deleteAddress(int addressId) async {
    if (_express) {
      await ExpressCheckout.instance.forgetAddress(addressId);
      return DeleteAddressResponse(status: 200, message: 'Removed', data: '');
    }
    return await _dataProvider.deleteAddress(addressId);
  }
}
