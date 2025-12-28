class LogoutResponse {
  final int status;
  final String message;
  final Map<String, dynamic> data;

  LogoutResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) => LogoutResponse(
    status: json['status'] as int,
    message: json['message'] as String? ?? '',
    data: json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data,
  };
}



