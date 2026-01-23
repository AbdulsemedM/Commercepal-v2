import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/features/auth/reset_password/data/models/reset_password_request.dart';
import 'package:commercepal/features/auth/reset_password/data/repository/reset_password_repository.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc({ResetPasswordRepository? repository})
    : _repository = repository ?? ResetPasswordRepository(),
      super(ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<ResetPasswordReset>(_onResetPasswordReset);
  }

  final ResetPasswordRepository _repository;

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(ResetPasswordLoading());

    try {
      final request = ResetPasswordRequest(
        target: event.target,
        verificationToken: event.verificationToken,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
        channel: event.channel ?? PlatformUtils.getChannel(),
      );

      final response = await _repository.resetPassword(request);

      emit(
        ResetPasswordSuccess(
          response.message.isNotEmpty
              ? response.message
              : 'Password has been reset successfully.',
        ),
      );
    } catch (e) {
      String errorMessage = 'Failed to reset password. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('400') || e.toString().contains('Bad Request')
            ? 'Invalid verification token or passwords do not match'
            : e.toString().contains('404') || e.toString().contains('Not Found')
            ? 'Invalid verification token'
            : errorMessage;
      }

      emit(ResetPasswordFailure(errorMessage));
    }
  }

  void _onResetPasswordReset(
    ResetPasswordReset event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(ResetPasswordInitial());
  }
}
