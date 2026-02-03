import 'affiliate_profile_data.dart';

class AffiliateMyProfileResponse {
  final int status;
  final String message;
  final AffiliateProfileData? data;

  AffiliateMyProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AffiliateMyProfileResponse.fromJson(Map<String, dynamic> json) =>
      AffiliateMyProfileResponse(
        status: json['status'] as int? ?? 0,
        message: json['message'] as String? ?? '',
        data: json['data'] != null
            ? AffiliateProfileData.fromJson(
                json['data'] as Map<String, dynamic>,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}
