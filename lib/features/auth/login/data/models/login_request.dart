class LoginRequest {
  final String loginIdentifier;
  final String password;
  final String channel;

  LoginRequest({
    required this.loginIdentifier,
    required this.password,
    this.channel = 'WEB',
  });

  Map<String, dynamic> toJson() => {
    'loginIdentifier': loginIdentifier,
    'password': password,
    'channel': channel,
  };
}
