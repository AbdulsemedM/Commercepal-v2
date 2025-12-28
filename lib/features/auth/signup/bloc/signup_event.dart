part of 'signup_bloc.dart';

@immutable
sealed class SignupEvent {}

final class SignupSubmitted extends SignupEvent {
  final String emailAddress;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String country;
  final String registrationChannel;

  SignupSubmitted({
    required this.emailAddress,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.country,
    this.registrationChannel = 'WEB',
  });
}

final class SignupReset extends SignupEvent {}
