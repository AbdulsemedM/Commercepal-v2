import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/core/utils/device_id_utils.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/features/affiliate_register/data/models/affiliate_register_request_dto.dart';
import 'package:commercepal/features/affiliate_register/data/repository/affiliate_register_repository.dart';

part 'affiliate_register_state.dart';

class AffiliateRegisterCubit extends Cubit<AffiliateRegisterState> {
  AffiliateRegisterCubit({AffiliateRegisterRepository? repository})
    : _repository = repository ?? AffiliateRegisterRepository(),
      super(AffiliateRegisterInitial());

  final AffiliateRegisterRepository _repository;

  Future<void> registerAffiliate({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String countryCode,
    required String country,
    required String password,
    required String confirmPassword,
    required String commissionType,
    required String referralCode,
  }) async {
    emit(AffiliateRegisterLoading());

    try {
      final deviceId = await DeviceIdUtils.getDeviceId();

      final request = AffiliateRegisterRequestDto(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        country: country,
        password: password,
        confirmPassword: confirmPassword,
        commissionType: commissionType.toUpperCase(),
        referralCode: referralCode,
        registrationChannel: PlatformUtils.getChannel(),
        deviceId: deviceId,
      );

      await _repository.register(request);
      emit(AffiliateRegisterSuccess());
    } catch (e) {
      emit(
        AffiliateRegisterFailure(
          e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Registration failed. Please try again.',
        ),
      );
    }
  }
}
