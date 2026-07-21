import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/features/affiliate/data/models/affiliate_profile_data.dart';
import 'package:commercepal/features/profile/data/models/profile_cache_payload.dart';
import 'package:commercepal/features/profile/data/models/update_profile_request.dart';
import 'package:commercepal/features/profile/data/repository/profile_repository.dart';
import 'package:commercepal/services/navigation_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    ProfileRepository? repository,
  })  : _repository = repository ?? ProfileRepository(),
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  final ProfileRepository _repository;

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final ProfileCachePayload? cached = await _repository.getCachedProfile();
    if (cached != null) {
      emit(_loadedFromCache(cached));
      return;
    }

    emit(ProfileLoading());
    try {
      final ProfileCachePayload payload =
          await _repository.refreshProfileCache();
      emit(_loadedFromCache(payload));
    } catch (e) {
      emit(ProfileError(_mapError(e, fallback: 'Failed to load profile. Please try again.')));
    }
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final ProfileState previous = state;
    final bool hadLoaded = previous is ProfileLoaded;

    try {
      final ProfileCachePayload payload =
          await _repository.refreshProfileCache();
      emit(_loadedFromCache(payload));
    } catch (e) {
      if (hadLoaded) {
        // Keep showing cached/current profile; surface a soft error via snackbar
        // only when nothing usable exists.
        emit(previous);
        return;
      }
      emit(ProfileError(
        _mapError(e, fallback: 'Failed to refresh profile. Please try again.'),
      ));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final AffiliateProfileData? affiliate = state is ProfileLoaded
        ? (state as ProfileLoaded).affiliateProfile
        : null;

    emit(ProfileLoading());

    try {
      final response = await _repository.updateProfile(event.request);
      emit(ProfileLoaded(response.data, affiliateProfile: affiliate));
    } catch (e) {
      emit(ProfileError(
        _mapError(e, fallback: 'Failed to update profile. Please try again.'),
      ));
    }
  }

  ProfileLoaded _loadedFromCache(ProfileCachePayload payload) {
    return ProfileLoaded(
      payload.profile,
      affiliateProfile: payload.affiliateProfile,
    );
  }

  String _mapError(Object e, {required String fallback}) {
    if (e is! Exception) return fallback;

    if (NavigationService.instance.handleSessionExpired(e)) {
      return 'Session expired. Please login again.';
    }

    final String text = e.toString();
    if (text.contains('401') || text.contains('Unauthorized')) {
      return 'Session expired. Please login again.';
    }
    if (text.contains('400') || text.contains('Bad Request')) {
      return 'Invalid information provided';
    }
    return fallback;
  }
}
