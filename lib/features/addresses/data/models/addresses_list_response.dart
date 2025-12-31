import 'address.dart';

class AddressesListResponse {
  final int status;
  final String message;
  final List<Address> data;

  AddressesListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AddressesListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return AddressesListResponse(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: dataList
          .map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.map((address) => address.toJson()).toList(),
  };
}
