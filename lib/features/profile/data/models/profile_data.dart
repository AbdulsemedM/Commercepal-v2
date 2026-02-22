class ProfileData {
  final String firstName;
  final String lastName;
  final String emailAddress;
  final String phoneNumber;
  final String country;
  final String? city;
  final String? stateProvince;
  final String? preferredLanguage;
  final String? preferredCurrency;
  final String? referralCode;
  final String registrationChannel;
  final String? customerNotes;
  final String? createdAt;
  final int? customerId;

  ProfileData({
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.phoneNumber,
    required this.country,
    this.city,
    this.stateProvince,
    this.preferredLanguage,
    this.preferredCurrency,
    this.referralCode,
    required this.registrationChannel,
    this.customerNotes,
    this.createdAt,
    this.customerId,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    emailAddress: json['emailAddress'] as String? ?? '',
    phoneNumber: json['phoneNumber'] as String? ?? '',
    country: json['country'] as String? ?? '',
    city: json['city'] as String?,
    stateProvince: json['stateProvince'] as String?,
    preferredLanguage: json['preferredLanguage'] as String?,
    preferredCurrency: json['preferredCurrency'] as String?,
    referralCode: json['referralCode'] as String?,
    registrationChannel: json['registrationChannel'] as String? ?? '',
    customerNotes: json['customerNotes'] as String?,
    createdAt: json['createdAt'] as String?,
    customerId: json['customerId'] as int? ?? json['id'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'emailAddress': emailAddress,
    'phoneNumber': phoneNumber,
    'country': country,
    if (city != null) 'city': city,
    if (stateProvince != null) 'stateProvince': stateProvince,
    if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
    if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
    if (referralCode != null) 'referralCode': referralCode,
    'registrationChannel': registrationChannel,
    if (customerNotes != null) 'customerNotes': customerNotes,
    if (createdAt != null) 'createdAt': createdAt,
    if (customerId != null) 'customerId': customerId,
  };

  String get fullName => '$firstName $lastName';
}
