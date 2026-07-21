import 'package:commercepal/features/affiliate/data/models/affiliate_profile_data.dart';
import 'package:commercepal/features/profile/data/models/profile_data.dart';

/// Persistent snapshot of profile (+ optional affiliate) for fast Profile UI.
class ProfileCachePayload {
  const ProfileCachePayload({
    required this.profile,
    this.affiliateProfile,
    required this.fetchedAt,
  });

  final ProfileData profile;
  final AffiliateProfileData? affiliateProfile;
  final DateTime fetchedAt;

  factory ProfileCachePayload.fromJson(Map<String, dynamic> json) {
    final Object? affiliateRaw = json['affiliateProfile'];
    return ProfileCachePayload(
      profile: ProfileData.fromJson(
        json['profile'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      affiliateProfile: affiliateRaw is Map<String, dynamic>
          ? AffiliateProfileData.fromJson(affiliateRaw)
          : null,
      fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'profile': profile.toJson(),
        if (affiliateProfile != null)
          'affiliateProfile': affiliateProfile!.toJson(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  ProfileCachePayload copyWith({
    ProfileData? profile,
    AffiliateProfileData? affiliateProfile,
    bool clearAffiliate = false,
    DateTime? fetchedAt,
  }) {
    return ProfileCachePayload(
      profile: profile ?? this.profile,
      affiliateProfile:
          clearAffiliate ? null : (affiliateProfile ?? this.affiliateProfile),
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
