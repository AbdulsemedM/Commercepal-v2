class DeleteAddressResponse {
  final int status;
  final String message;
  final String data;

  DeleteAddressResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DeleteAddressResponse.fromJson(Map<String, dynamic> json) =>
      DeleteAddressResponse(
        status: json['status'] as int? ?? 0,
        message: json['message'] as String? ?? '',
        data: json['data'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data,
  };
}
