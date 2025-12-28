import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/features/auth/change_password/data/models/change_password_request.dart';
import 'package:commercepal/features/auth/change_password/data/repository/change_password_repository.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc({ChangePasswordRepository? repository})
    : _repository = repository ?? ChangePasswordRepository(),
      super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
    on<ChangePasswordReset>(_onChangePasswordReset);
  }

  final ChangePasswordRepository _repository;

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(ChangePasswordLoading());

    try {
      final request = ChangePasswordRequest(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
        channel: event.channel,
      );

      final response = await _repository.changePassword(request);

      emit(
        ChangePasswordSuccess(
          response.message.isNotEmpty
              ? response.message
              : 'Password has been changed successfully.',
        ),
      );
    } catch (e) {
      String errorMessage = 'Failed to change password. Please try again.';

      if (e is Exception) {
        errorMessage =
            e.toString().contains('400') || e.toString().contains('Bad Request')
            ? 'Current password is incorrect or passwords do not match'
            : e.toString().contains('401') ||
                  e.toString().contains('Unauthorized')
            ? 'Current password is incorrect'
            : errorMessage;
      }

      emit(ChangePasswordFailure(errorMessage));
    }
  }

  void _onChangePasswordReset(
    ChangePasswordReset event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(ChangePasswordInitial());
  }
}
