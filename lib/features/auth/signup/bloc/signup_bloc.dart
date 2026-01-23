import 'package:bloc/bloc.dart';
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
        registrationChannel: event.registrationChannel ?? PlatformUtils.getChannel(),
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

      if (e is Exception) {
        errorMessage =
            e.toString().contains('400') || e.toString().contains('Bad Request')
            ? 'Invalid information provided'
            : e.toString().contains('409') || e.toString().contains('Conflict')
            ? 'Email or phone number already exists'
            : errorMessage;
      }

      emit(SignupFailure(errorMessage));
    }
  }

  void _onSignupReset(SignupReset event, Emitter<SignupState> emit) {
    emit(SignupInitial());
  }
}
