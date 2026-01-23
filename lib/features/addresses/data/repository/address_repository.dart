import '../data_provider/address_data_provider.dart';
import '../models/address.dart';
import '../models/add_address_request.dart';
import '../models/update_address_request.dart';
import '../models/delete_address_response.dart';

class AddressRepository {
  AddressRepository({AddressDataProvider? dataProvider})
    : _dataProvider = dataProvider ?? AddressDataProvider();

  final AddressDataProvider _dataProvider;

  Future<Address> addAddress(AddAddressRequest request) async {
    return await _dataProvider.addAddress(request);
  }

  Future<List<Address>> getAllAddresses() async {
    return await _dataProvider.getAllAddresses();
  }

  Future<Address> updateAddress(
    int addressId,
    UpdateAddressRequest request,
  ) async {
    return await _dataProvider.updateAddress(addressId, request);
  }

  Future<Address> setDefaultAddress(int addressId) async {
    return await _dataProvider.setDefaultAddress(addressId);
  }

  Future<DeleteAddressResponse> deleteAddress(int addressId) async {
    return await _dataProvider.deleteAddress(addressId);
  }
}
