class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final String? accessToken =
        json['accessToken'] as String? ?? json['token'] as String?;
    final String? refreshToken = json['refreshToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw FormatException('Login response missing accessToken');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw FormatException('Login response missing refreshToken');
    }
    return LoginResponse(
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
