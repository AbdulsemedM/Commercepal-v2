import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/features/affiliate/data/models/affiliate_profile_data.dart';
import 'package:commercepal/features/affiliate/data/repository/affiliate_repository.dart';
import 'package:commercepal/features/profile/data/models/profile_data.dart';
import 'package:commercepal/features/profile/data/models/update_profile_request.dart';
import 'package:commercepal/features/profile/data/repository/profile_repository.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/navigation_service.dart';
import 'package:commercepal/core/storage/storage.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    ProfileRepository? repository,
    AffiliateRepository? affiliateRepository,
    AuthService? authService,
    Storage? storage,
  })  : _repository = repository ?? ProfileRepository(),
        _affiliateRepository = affiliateRepository ?? AffiliateRepository(),
        _authService = authService ?? AuthService(),
        _storage = storage ?? Storage(),
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  final ProfileRepository _repository;
  final AffiliateRepository _affiliateRepository;
  final AuthService _authService;
  final Storage _storage;

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final response = await _repository.getProfile();
      print('🟣 ProfileBloc._onProfileLoadRequested: Profile loaded, customerId: ${response.data.customerId}');

      // Save customerId if available
      if (response.data.customerId != null) {
        print('🟣 ProfileBloc._onProfileLoadRequested: Saving customerId to storage: ${response.data.customerId}');
        await _storage.saveCustomerId(response.data.customerId!);
        print('🟣 ProfileBloc._onProfileLoadRequested: customerId saved successfully');
      } else {
        print('⚠️ ProfileBloc._onProfileLoadRequested: customerId is null in profile response!');
      }

      // Update auth service with profile data
      _authService.updateProfile(
        userName: response.data.fullName,
        userEmail: response.data.emailAddress,
      );

      AffiliateProfileData? affiliateProfile;
      try {
        final affiliateResponse = await _affiliateRepository.getMyProfile();
        affiliateProfile = affiliateResponse?.data;
      } catch (_) {
        // User is not an affiliate or request failed
      }

      emit(ProfileLoaded(response.data, affiliateProfile: affiliateProfile));
    } catch (e) {
      String errorMessage = 'Failed to load profile. Please try again.';

      if (e is Exception) {
        if (NavigationService.instance.handleSessionExpired(e)) {
          errorMessage = 'Session expired. Please login again.';
        } else {
          errorMessage =
              e.toString().contains('401') ||
                  e.toString().contains('Unauthorized')
              ? 'Session expired. Please login again.'
              : errorMessage;
        }
      }

      emit(ProfileError(errorMessage));
    }
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      emit(ProfileLoading());
    }

    try {
      final response = await _repository.getProfile();
      print('🟣 ProfileBloc._onProfileRefreshRequested: Profile loaded, customerId: ${response.data.customerId}');

      // Save customerId if available
      if (response.data.customerId != null) {
        print('🟣 ProfileBloc._onProfileRefreshRequested: Saving customerId to storage: ${response.data.customerId}');
        await _storage.saveCustomerId(response.data.customerId!);
        print('🟣 ProfileBloc._onProfileRefreshRequested: customerId saved successfully');
      } else {
        print('⚠️ ProfileBloc._onProfileRefreshRequested: customerId is null in profile response!');
      }

      // Update auth service with profile data
      _authService.updateProfile(
        userName: response.data.fullName,
        userEmail: response.data.emailAddress,
      );

      AffiliateProfileData? affiliateProfile;
      try {
        final affiliateResponse = await _affiliateRepository.getMyProfile();
        affiliateProfile = affiliateResponse?.data;
      } catch (_) {
        // User is not an affiliate or request failed
      }

      emit(ProfileLoaded(response.data, affiliateProfile: affiliateProfile));
    } catch (e) {
      String errorMessage = 'Failed to refresh profile. Please try again.';

      if (e is Exception) {
        if (NavigationService.instance.handleSessionExpired(e)) {
          errorMessage = 'Session expired. Please login again.';
        } else {
          errorMessage =
              e.toString().contains('401') ||
                  e.toString().contains('Unauthorized')
              ? 'Session expired. Please login again.'
              : errorMessage;
        }
      }

      emit(ProfileError(errorMessage));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final response = await _repository.updateProfile(event.request);
      print('🟣 ProfileBloc._onProfileUpdateRequested: Profile updated, customerId: ${response.data.customerId}');

      // Save customerId if available
      if (response.data.customerId != null) {
        print('🟣 ProfileBloc._onProfileUpdateRequested: Saving customerId to storage: ${response.data.customerId}');
        await _storage.saveCustomerId(response.data.customerId!);
        print('🟣 ProfileBloc._onProfileUpdateRequested: customerId saved successfully');
      } else {
        print('⚠️ ProfileBloc._onProfileUpdateRequested: customerId is null in profile response!');
      }

      // Update auth service with profile data
      _authService.updateProfile(
        userName: response.data.fullName,
        userEmail: response.data.emailAddress,
      );

      final affiliateProfile = state is ProfileLoaded
          ? (state as ProfileLoaded).affiliateProfile
          : null;
      emit(ProfileLoaded(response.data, affiliateProfile: affiliateProfile));
    } catch (e) {
      String errorMessage = 'Failed to update profile. Please try again.';

      if (e is Exception) {
        if (NavigationService.instance.handleSessionExpired(e)) {
          errorMessage = 'Session expired. Please login again.';
        } else {
          errorMessage =
              e.toString().contains('401') ||
                  e.toString().contains('Unauthorized')
              ? 'Session expired. Please login again.'
              : e.toString().contains('400') ||
                    e.toString().contains('Bad Request')
              ? 'Invalid information provided'
              : errorMessage;
        }
      }

      emit(ProfileError(errorMessage));
    }
  }
}
