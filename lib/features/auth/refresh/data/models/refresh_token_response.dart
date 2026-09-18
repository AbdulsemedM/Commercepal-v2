class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    final String? accessToken =
        json['accessToken'] as String? ?? json['token'] as String?;
    final String? refreshToken = json['refreshToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw FormatException('Refresh response missing accessToken');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw FormatException('Refresh response missing refreshToken');
    }
    return RefreshTokenResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 3600,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'expiresIn': expiresIn,
  };
}
