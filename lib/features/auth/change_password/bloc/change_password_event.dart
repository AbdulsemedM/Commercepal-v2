part of 'change_password_bloc.dart';

@immutable
sealed class ChangePasswordEvent {}

final class ChangePasswordSubmitted extends ChangePasswordEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final String channel;

  ChangePasswordSubmitted({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
    this.channel = 'WEB',
  });
}

final class ChangePasswordReset extends ChangePasswordEvent {}
