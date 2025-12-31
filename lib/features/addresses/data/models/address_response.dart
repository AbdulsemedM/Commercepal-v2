import 'address.dart';

class AddressResponse {
  final int status;
  final String message;
  final Address data;

  AddressResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      AddressResponse(
        status: json['status'] as int? ?? 0,
        message: json['message'] as String? ?? '',
        data: Address.fromJson(json['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}
