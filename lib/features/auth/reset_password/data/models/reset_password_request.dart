import 'package:commercepal/core/utils/platform_utils.dart';

/// Body for POST /api/credentials/password/reset (matches API validation).
class ResetPasswordRequest {
  final String target;
  final String verificationToken;
  final String newPassword;
  final String confirmPassword;
  final String channel;

  ResetPasswordRequest({
    required this.target,
    required this.verificationToken,
    required this.newPassword,
    required this.confirmPassword,
    String? channel,
  }) : channel = channel ?? PlatformUtils.getChannel();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'target': target,
        'verificationToken': verificationToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
        'channel': channel,
      };
}
