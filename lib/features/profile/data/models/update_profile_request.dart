import 'profile_data.dart';

class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String country;
  final String? city;
  final String? stateProvince;
  final String? preferredLanguage;
  final String? preferredCurrency;
  final String? customerNotes;

  UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.country,
    this.city,
    this.stateProvince,
    this.preferredLanguage,
    this.preferredCurrency,
    this.customerNotes,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'country': country,
    if (city != null) 'city': city,
    if (stateProvince != null) 'stateProvince': stateProvince,
    if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
    if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
    if (customerNotes != null) 'customerNotes': customerNotes,
  };

  factory UpdateProfileRequest.fromProfileData(ProfileData profile) {
    return UpdateProfileRequest(
      firstName: profile.firstName,
      lastName: profile.lastName,
      country: profile.country,
      city: profile.city,
      stateProvince: profile.stateProvince,
      preferredLanguage: profile.preferredLanguage,
      preferredCurrency: profile.preferredCurrency,
      customerNotes: profile.customerNotes,
    );
  }
}
