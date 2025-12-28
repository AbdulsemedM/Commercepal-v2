import 'profile_data.dart';

class ProfileResponse {
  final int status;
  final String message;
  final ProfileData data;

  ProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      ProfileResponse(
        status: json['status'] as int,
        message: json['message'] as String? ?? '',
        data: ProfileData.fromJson(json['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}
