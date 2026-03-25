import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/features/auth/signup/data/models/signup_request.dart';
import 'package:commercepal/features/auth/signup/data/repository/signup_repository.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({SignupRepository? repository})
    : _repository = repository ?? SignupRepository(),
      super(SignupInitial()) {
    on<SignupSubmitted>(_onSignupSubmitted);
    on<SignupReset>(_onSignupReset);
  }

  final SignupRepository _repository;

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    try {
      final request = SignupRequest(
        emailAddress: event.emailAddress,
        phoneNumber: event.phoneNumber,
        password: event.password,
        confirmPassword: event.confirmPassword,
        firstName: event.firstName,
        lastName: event.lastName,
        country: event.country,
        registrationChannel:
            event.registrationChannel ??
            (PlatformUtils.isIOS ? 'MOBILE_APP_IOS' : 'MOBILE_APP_ANDROID'),
      );

      final response = await _repository.signup(request);

      emit(
        SignupSuccess(
          response.message.isNotEmpty
              ? response.message
              : 'Account created successfully. Please login.',
        ),
      );
    } catch (e) {
      String errorMessage = 'Failed to create account. Please try again.';

      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        final apiMessage = data['message'] as String?;
        if (apiMessage != null && apiMessage.isNotEmpty) {
          errorMessage = apiMessage;
        }
      }

      emit(SignupFailure(errorMessage));
    }
  }

  void _onSignupReset(SignupReset event, Emitter<SignupState> emit) {
    emit(SignupInitial());
  }
}
