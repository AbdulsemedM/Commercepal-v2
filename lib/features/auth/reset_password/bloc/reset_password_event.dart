part of 'reset_password_bloc.dart';

@immutable
sealed class ResetPasswordEvent {}

final class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String emailOrPhone;
  final String verificationCode;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordSubmitted({
    required this.emailOrPhone,
    required this.verificationCode,
    required this.newPassword,
    required this.confirmPassword,
  });
}

final class ResetPasswordReset extends ResetPasswordEvent {}
