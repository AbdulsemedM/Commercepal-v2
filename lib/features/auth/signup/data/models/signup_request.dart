class SignupRequest {
  final String emailAddress;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String country;
  final String registrationChannel;

  /// Affiliate code that referred the customer (sent as both fields, as web).
  final String? referralCode;

  SignupRequest({
    required this.emailAddress,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.registrationChannel,
    this.referralCode,
  });

  Map<String, dynamic> toJson() => {
    'emailAddress': emailAddress,
    'phoneNumber': phoneNumber,
    'password': password,
    'confirmPassword': confirmPassword,
    'firstName': firstName,
    'lastName': lastName,
    'country': country,
    'registrationChannel': registrationChannel,
    if (referralCode != null && referralCode!.isNotEmpty) ...{
      'referralCode': referralCode,
      'affiliateReferralCode': referralCode,
    },
  };
}
