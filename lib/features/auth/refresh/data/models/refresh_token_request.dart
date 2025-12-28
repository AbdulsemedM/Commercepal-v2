class RefreshTokenRequest {
  final String refreshToken;
  final String channel;

  RefreshTokenRequest({required this.refreshToken, this.channel = 'WEB'});

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
    'channel': channel,
  };
}
