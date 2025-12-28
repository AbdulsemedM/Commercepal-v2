part of 'reset_password_bloc.dart';

@immutable
sealed class ResetPasswordEvent {}

final class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String target;
  final String verificationToken;
  final String newPassword;
  final String confirmPassword;
  final String channel;

  ResetPasswordSubmitted({
    required this.target,
    required this.verificationToken,
    required this.newPassword,
    required this.confirmPassword,
    this.channel = 'WEB',
  });
}

final class ResetPasswordReset extends ResetPasswordEvent {}
