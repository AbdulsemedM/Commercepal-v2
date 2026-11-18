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

/// Passwordless login step 1: send a code to the phone/email. [firstName] is
/// only needed for a phone that has no account yet (the backend creates it).
final class OtpCodeRequested extends LoginEvent {
  final String identifier;
  final bool usedPhoneLogin;
  final String? firstName;
  final String? countryCode;

  OtpCodeRequested({
    required this.identifier,
    this.usedPhoneLogin = false,
    this.firstName,
    this.countryCode,
  });
}

/// Passwordless login step 2: verify the code that was sent.
final class OtpVerifySubmitted extends LoginEvent {
  final String identifier;
  final String code;
  final bool usedPhoneLogin;
  final bool rememberMe;
  final String? channel;

  OtpVerifySubmitted({
    required this.identifier,
    required this.code,
    this.usedPhoneLogin = false,
    this.rememberMe = false,
    this.channel,
  });
}
