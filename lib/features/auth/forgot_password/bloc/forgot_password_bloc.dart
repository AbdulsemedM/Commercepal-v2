import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/features/auth/forgot_password/data/models/forgot_password_request.dart';
import 'package:commercepal/features/auth/forgot_password/data/repository/forgot_password_repository.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({ForgotPasswordRepository? repository})
    : _repository = repository ?? ForgotPasswordRepository(),
      super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ForgotPasswordReset>(_onForgotPasswordReset);
  }

  final ForgotPasswordRepository _repository;

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());

    try {
      final request = ForgotPasswordRequest(
        emailOrPhone: event.emailOrPhone,
        channel: event.channel ?? PlatformUtils.getChannel(),
      );

      final response = await _repository.forgotPassword(request);

      emit(
        ForgotPasswordSuccess(
          response.message.isNotEmpty
              ? response.message
              : 'Password reset instructions have been sent to your email/phone.',
        ),
      );
    } catch (e) {
      String errorMessage =
          'Failed to send reset instructions. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('404') || e.toString().contains('Not Found')
            ? 'Email or phone number not found'
            : errorMessage;
      }

      emit(ForgotPasswordFailure(errorMessage));
    }
  }

  void _onForgotPasswordReset(
    ForgotPasswordReset event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(ForgotPasswordInitial());
  }
}
