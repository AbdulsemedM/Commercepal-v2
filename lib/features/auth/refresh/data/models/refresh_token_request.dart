import 'package:commercepal/core/utils/platform_utils.dart';

class RefreshTokenRequest {
  final String refreshToken;
  final String channel;

  RefreshTokenRequest({
    required this.refreshToken,
    String? channel,
  }) : channel = channel ?? PlatformUtils.getAuthChannel();

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
    'channel': channel,
  };
}
