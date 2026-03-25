class SignupResponse {
  final int status;
  final String message;
  final Object? data;

  SignupResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) => SignupResponse(
    status: json['status'] as int,
    message: json['message'] as String? ?? '',
    data: json['data'],
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data,
  };
}
