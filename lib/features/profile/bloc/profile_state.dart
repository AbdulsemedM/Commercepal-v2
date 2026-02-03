part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final ProfileData profile;
  final AffiliateProfileData? affiliateProfile;

  ProfileLoaded(this.profile, {this.affiliateProfile});
}

final class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
