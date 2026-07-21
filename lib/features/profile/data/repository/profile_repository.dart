import 'dart:convert';

import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/affiliate/data/models/affiliate_profile_data.dart';
import 'package:commercepal/features/affiliate/data/repository/affiliate_repository.dart';
import 'package:commercepal/features/profile/data/models/profile_cache_payload.dart';
import 'package:commercepal/services/auth_service.dart';

import '../data_provider/profile_data_provider.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';

class ProfileRepository {
  ProfileRepository({
    ProfileDataProvider? dataProvider,
    AffiliateRepository? affiliateRepository,
    Storage? storage,
    AuthService? authService,
  })  : _dataProvider = dataProvider ?? ProfileDataProvider(),
        _affiliateRepository = affiliateRepository ?? AffiliateRepository(),
        _storage = storage ?? Storage(),
        _authService = authService ?? AuthService();

  final ProfileDataProvider _dataProvider;
  final AffiliateRepository _affiliateRepository;
  final Storage _storage;
  final AuthService _authService;

  Future<ProfileResponse> getProfile() async {
    return await _dataProvider.getProfile();
  }

  /// Returns cached profile snapshot, or null if missing/corrupt.
  Future<ProfileCachePayload?> getCachedProfile() async {
    final String? raw = await _storage.getProfileCacheJson();
    if (raw == null || raw.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final ProfileCachePayload payload = ProfileCachePayload.fromJson(decoded);
      if (payload.profile.emailAddress.isEmpty &&
          payload.profile.firstName.isEmpty &&
          payload.profile.lastName.isEmpty) {
        return null;
      }
      return payload;
    } catch (_) {
      return null;
    }
  }

  /// Fetches profile + affiliate from network, persists cache, syncs AuthService.
  Future<ProfileCachePayload> refreshProfileCache() async {
    final ProfileResponse response = await _dataProvider.getProfile();
    await _persistCustomerAndAuth(response);

    AffiliateProfileData? affiliateProfile;
    try {
      final affiliateResponse = await _affiliateRepository.getMyProfile();
      affiliateProfile = affiliateResponse?.data;
    } catch (_) {
      // User is not an affiliate or request failed — keep affiliate null.
    }

    final ProfileCachePayload payload = ProfileCachePayload(
      profile: response.data,
      affiliateProfile: affiliateProfile,
      fetchedAt: DateTime.now().toUtc(),
    );
    await _savePayload(payload);
    return payload;
  }

  Future<ProfileResponse> updateProfile(UpdateProfileRequest request) async {
    final ProfileResponse response =
        await _dataProvider.updateProfile(request);
    await _persistCustomerAndAuth(response);

    final ProfileCachePayload? existing = await getCachedProfile();
    final ProfileCachePayload payload = ProfileCachePayload(
      profile: response.data,
      affiliateProfile: existing?.affiliateProfile,
      fetchedAt: DateTime.now().toUtc(),
    );
    await _savePayload(payload);
    return response;
  }

  Future<void> deleteAccount() async {
    await _dataProvider.deleteAccount();
  }

  Future<void> clearCache() async {
    await _storage.clearProfileCache();
  }

  Future<void> _savePayload(ProfileCachePayload payload) async {
    await _storage.saveProfileCacheJson(jsonEncode(payload.toJson()));
  }

  Future<void> _persistCustomerAndAuth(ProfileResponse response) async {
    if (response.data.customerId != null) {
      await _storage.saveCustomerId(response.data.customerId!);
    }
    _authService.updateProfile(
      userName: response.data.fullName,
      userEmail: response.data.emailAddress,
    );
  }
}
