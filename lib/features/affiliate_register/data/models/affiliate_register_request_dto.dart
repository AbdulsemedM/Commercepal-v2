class AffiliateRegisterRequestDto {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String countryCode;
  final String country;
  final String password;
  final String confirmPassword;
  final String commissionType;
  final String referralCode;
  final String registrationChannel;
  final String deviceId;

  AffiliateRegisterRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.countryCode,
    required this.country,
    required this.password,
    required this.confirmPassword,
    required this.commissionType,
    required this.referralCode,
    required this.registrationChannel,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
        'country': country,
        'password': password,
        'confirmPassword': confirmPassword,
        'commissionType': commissionType,
        'referralCode': referralCode,
        'registrationChannel': registrationChannel,
        'deviceId': deviceId,
      };
}
