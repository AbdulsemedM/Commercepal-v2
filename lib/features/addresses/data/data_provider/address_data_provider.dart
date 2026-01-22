import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/address.dart';
import '../models/add_address_request.dart';
import '../models/update_address_request.dart';
// import '../models/address_response.dart';
import '../models/addresses_list_response.dart';
import '../models/delete_address_response.dart';

class AddressDataProvider {
  AddressDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/customers/addresses';

  Future<Address> addAddress(AddAddressRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        _endpoint,
        data: request.toJson(),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      // Extract nested data field
      final responseData = response.data!;
      final addressData = responseData['data'] as Map<String, dynamic>?;
      
      if (addressData == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response format from server',
        );
      }

      return Address.fromJson(addressData);
    } on DioException catch (e) {
      AppLogger.e('Add address failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during add address',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<List<Address>> getAllAddresses() async {
    try {
      final response = await _apiService.get<dynamic>(_endpoint);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      // Handle both wrapped response and direct list
      if (response.data is List) {
        final dataList = response.data as List<dynamic>;
        return dataList
            .map((item) => Address.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map<String, dynamic>) {
        final addressesListResponse = AddressesListResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return addressesListResponse.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response format from server',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('Get all addresses failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get all addresses',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<Address> updateAddress(
    int addressId,
    UpdateAddressRequest request,
  ) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '$_endpoint/$addressId',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      // Extract nested data field
      final responseData = response.data!;
      final addressData = responseData['data'] as Map<String, dynamic>?;
      
      if (addressData == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response format from server',
        );
      }

      return Address.fromJson(addressData);
    } on DioException catch (e) {
      AppLogger.e('Update address failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during update address',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<Address> setDefaultAddress(int addressId) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '$_endpoint/$addressId/default',
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      // Extract nested data field
      final responseData = response.data!;
      final addressData = responseData['data'] as Map<String, dynamic>?;
      
      if (addressData == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response format from server',
        );
      }

      return Address.fromJson(addressData);
    } on DioException catch (e) {
      AppLogger.e('Set default address failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during set default address',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<DeleteAddressResponse> deleteAddress(int addressId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '$_endpoint/$addressId',
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      return DeleteAddressResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Delete address failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during delete address',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
