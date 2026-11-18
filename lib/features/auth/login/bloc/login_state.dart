part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final String accessToken;
  final String refreshToken;

  LoginSuccess({required this.accessToken, required this.refreshToken});
}

final class LoginFailure extends LoginState {
  final String message;
  final bool isInvalidCredentials;
  final bool usedPhoneLogin;

  LoginFailure(
    this.message, {
    this.isInvalidCredentials = false,
    this.usedPhoneLogin = false,
  });
}

/// A login code was sent; [sentTo] is the masked phone/email.
final class OtpCodeSent extends LoginState {
  final String identifier;
  final String sentTo;

  OtpCodeSent({required this.identifier, required this.sentTo});
}

/// The phone has no account yet: ask for a name, then request the code again.
final class OtpNameRequired extends LoginState {
  final String message;

  OtpNameRequired(this.message);
}
