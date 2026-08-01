import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

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
        emailOrPhone: event.emailOrPhone,
        verificationCode: event.verificationCode,
        newPassword: event.newPassword,
      );

      final response = await _repository.resetPassword(request);

      emit(
        ResetPasswordSuccess(
          response.message.isNotEmpty
              ? response.message
              : 'Password reset successfully! You can now login with your new password.',
        ),
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverMessage = _extractMessage(e.response?.data);
      String errorMessage = 'Failed to reset password. Please try again.';

      if (status == 429) {
        errorMessage =
            serverMessage ?? 'Too many attempts. Please try again later.';
      } else if (status == 404) {
        errorMessage = serverMessage ?? 'User not found.';
      } else if (status == 400) {
        errorMessage = serverMessage ??
            'Invalid or expired verification code.';
      }

      emit(ResetPasswordFailure(errorMessage));
    } catch (_) {
      emit(
        ResetPasswordFailure(
          'Failed to reset password. Please try again.',
        ),
      );
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
  }

  void _onResetPasswordReset(
    ResetPasswordReset event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(ResetPasswordInitial());
  }
}
