import '../../../addresses/data/models/address.dart';

class ShippingAddress {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String country;

  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
  });

  factory ShippingAddress.fromAddress(Address address) {
    final String line = _firstNonEmpty(<String?>[
      address.addressLine1,
      _joinNonEmpty(<String>[
        address.street,
        address.houseNumber,
        if (address.landmark != null && address.landmark!.isNotEmpty)
          address.landmark!,
      ]),
      address.district,
    ]);

    return ShippingAddress(
      fullName: address.receiverName,
      phone: address.phoneNumber,
      address: line,
      city: address.city,
      country: address.country,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'country': country,
      };

  static String _firstNonEmpty(List<String?> values) {
    for (final String? value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  static String _joinNonEmpty(List<String> values) {
    return values
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .join(', ');
  }
}
