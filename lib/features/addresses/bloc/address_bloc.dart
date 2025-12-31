import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/models/address.dart';
import '../data/models/add_address_request.dart';
import '../data/models/update_address_request.dart';
import '../data/models/delete_address_response.dart';
import '../data/repository/address_repository.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc({AddressRepository? repository})
    : _repository = repository ?? AddressRepository(),
      super(AddressInitial()) {
    on<AddressLoadRequested>(_onAddressLoadRequested);
    on<AddressAddRequested>(_onAddressAddRequested);
    on<AddressUpdateRequested>(_onAddressUpdateRequested);
    on<AddressSetDefaultRequested>(_onAddressSetDefaultRequested);
    on<AddressDeleteRequested>(_onAddressDeleteRequested);
    on<AddressRefreshRequested>(_onAddressRefreshRequested);
  }

  final AddressRepository _repository;

  Future<void> _onAddressLoadRequested(
    AddressLoadRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final addresses = await _repository.getAllAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      String errorMessage = 'Failed to load addresses. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : errorMessage;
      }

      emit(AddressError(errorMessage));
    }
  }

  Future<void> _onAddressAddRequested(
    AddressAddRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final address = await _repository.addAddress(event.request);
      emit(AddressAdded(address));

      // Refresh the list
      final addresses = await _repository.getAllAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      String errorMessage = 'Failed to add address. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : errorMessage;
      }

      emit(AddressError(errorMessage));
    }
  }

  Future<void> _onAddressUpdateRequested(
    AddressUpdateRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final address = await _repository.updateAddress(
        event.addressId,
        event.request,
      );
      emit(AddressUpdated(address));

      // Refresh the list
      final addresses = await _repository.getAllAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      String errorMessage = 'Failed to update address. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : errorMessage;
      }

      emit(AddressError(errorMessage));
    }
  }

  Future<void> _onAddressSetDefaultRequested(
    AddressSetDefaultRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final address = await _repository.setDefaultAddress(event.addressId);
      emit(AddressSetDefault(address));

      // Refresh the list
      final addresses = await _repository.getAllAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      String errorMessage = 'Failed to set default address. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : errorMessage;
      }

      emit(AddressError(errorMessage));
    }
  }

  Future<void> _onAddressDeleteRequested(
    AddressDeleteRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final response = await _repository.deleteAddress(event.addressId);
      emit(AddressDeleted(response));

      // Refresh the list
      final addresses = await _repository.getAllAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      String errorMessage = 'Failed to delete address. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : errorMessage;
      }

      emit(AddressError(errorMessage));
    }
  }

  Future<void> _onAddressRefreshRequested(
    AddressRefreshRequested event,
    Emitter<AddressState> emit,
  ) async {
    try {
      final addresses = await _repository.getAllAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      String errorMessage = 'Failed to refresh addresses. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Session expired. Please login again.'
            : errorMessage;
      }

      emit(AddressError(errorMessage));
    }
  }
}
