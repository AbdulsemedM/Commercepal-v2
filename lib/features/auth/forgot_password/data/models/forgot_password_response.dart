class ForgotPasswordResponse {
  final int status;
  final String message;
  final Map<String, dynamic> data;

  ForgotPasswordResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponse(
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
