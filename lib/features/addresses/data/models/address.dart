class Address {
  final int id;
  final bool isDefault;
  final bool canEdit;
  final bool canDelete;
  final String receiverName;
  final String phoneNumber;
  final String country;
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
  final String? createdAt;
  final String? updatedAt;

  Address({
    required this.id,
    required this.isDefault,
    required this.canEdit,
    required this.canDelete,
    required this.receiverName,
    required this.phoneNumber,
    required this.country,
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
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as int,
    isDefault: json['isDefault'] as bool? ?? false,
    canEdit: json['canEdit'] as bool? ?? true,
    canDelete: json['canDelete'] as bool? ?? true,
    receiverName: json['receiverName'] as String,
    phoneNumber: json['phoneNumber'] as String,
    country: json['country'] as String? ?? json['countryCode'] as String? ?? '',
    state: json['state'] as String,
    city: json['city'] as String,
    district: json['district'] as String,
    street: json['street'] as String,
    houseNumber: json['houseNumber'] as String,
    landmark: json['landmark'] as String?,
    addressLine1: json['addressLine1'] as String?,
    addressLine2: json['addressLine2'] as String?,
    latitude: json['latitude'] as String,
    longitude: json['longitude'] as String,
    addressSource: json['addressSource'] as String,
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'isDefault': isDefault,
    'canEdit': canEdit,
    'canDelete': canDelete,
    'receiverName': receiverName,
    'phoneNumber': phoneNumber,
    'country': country,
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
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };
}
