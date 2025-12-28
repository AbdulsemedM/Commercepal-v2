part of 'reset_password_bloc.dart';

@immutable
sealed class ResetPasswordState {}

final class ResetPasswordInitial extends ResetPasswordState {}

final class ResetPasswordLoading extends ResetPasswordState {}

final class ResetPasswordSuccess extends ResetPasswordState {
  final String message;

  ResetPasswordSuccess(this.message);
}

final class ResetPasswordFailure extends ResetPasswordState {
  final String message;

  ResetPasswordFailure(this.message);
}
