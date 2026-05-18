part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

final class LoginSubmitted extends LoginEvent {
  final String loginIdentifier;
  final String password;
  final String? channel;
  final bool rememberMe;
  final bool usedPhoneLogin;

  LoginSubmitted({
    required this.loginIdentifier,
    required this.password,
    this.channel,
    this.rememberMe = false,
    this.usedPhoneLogin = false,
  });
}

final class GoogleSignInRequested extends LoginEvent {
  final String? channel;

  GoogleSignInRequested({this.channel});
}

final class LoginReset extends LoginEvent {}
