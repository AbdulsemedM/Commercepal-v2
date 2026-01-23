part of 'forgot_password_bloc.dart';

@immutable
sealed class ForgotPasswordEvent {}

final class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  final String emailOrPhone;
  final String? channel;

  ForgotPasswordSubmitted({required this.emailOrPhone, this.channel});
}

final class ForgotPasswordReset extends ForgotPasswordEvent {}
