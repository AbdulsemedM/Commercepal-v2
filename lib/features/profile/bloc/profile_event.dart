part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class ProfileLoadRequested extends ProfileEvent {}

final class ProfileRefreshRequested extends ProfileEvent {}

final class ProfileUpdateRequested extends ProfileEvent {
  final UpdateProfileRequest request;

  ProfileUpdateRequested(this.request);
}
