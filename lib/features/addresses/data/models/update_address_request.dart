class UpdateAddressRequest {
  final String receiverName;
  final String phoneNumber;
  final String countryCode;
  final String state;
  final String city;
  final String district;
  final String street;
  final String houseNumber;
  final String? landmark;
  final String? addressLine1;
  final String? addressLine2;
  final String latitude;
  final String longitude;
  final String addressSource;
  final bool isDefault;

  UpdateAddressRequest({
    required this.receiverName,
    required this.phoneNumber,
    required this.countryCode,
    required this.state,
    required this.city,
    required this.district,
    required this.street,
    required this.houseNumber,
    this.landmark,
    this.addressLine1,
    this.addressLine2,
    required this.latitude,
    required this.longitude,
    required this.addressSource,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() => {
    'receiverName': receiverName,
    'phoneNumber': phoneNumber,
    'countryCode': countryCode,
    'state': state,
    'city': city,
    'district': district,
    'street': street,
    'houseNumber': houseNumber,
    if (landmark != null) 'landmark': landmark,
    if (addressLine1 != null) 'addressLine1': addressLine1,
    if (addressLine2 != null) 'addressLine2': addressLine2,
    'latitude': latitude,
    'longitude': longitude,
    'addressSource': addressSource,
    'isDefault': isDefault,
  };
}
