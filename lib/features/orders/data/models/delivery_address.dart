class DeliveryAddress {
  final String fullName;
  final String streetAddress;
  final String city;
  final String subcity;
  final String region;
  final String phoneNumber;
  final String postalCode;
  final String country;
  final String formattedAddress;

  DeliveryAddress({
    required this.fullName,
    required this.streetAddress,
    required this.city,
    required this.subcity,
    required this.region,
    required this.phoneNumber,
    required this.postalCode,
    required this.country,
    required this.formattedAddress,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
        fullName: json['fullName'] as String? ?? '',
        streetAddress: json['streetAddress'] as String? ?? '',
        city: json['city'] as String? ?? '',
        subcity: json['subcity'] as String? ?? '',
        region: json['region'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
        country: json['country'] as String? ?? '',
        formattedAddress: json['formattedAddress'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'streetAddress': streetAddress,
        'city': city,
        'subcity': subcity,
        'region': region,
        'phoneNumber': phoneNumber,
        'postalCode': postalCode,
        'country': country,
        'formattedAddress': formattedAddress,
      };
}
