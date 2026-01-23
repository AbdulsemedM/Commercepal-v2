class LoginRequest {
  final String loginIdentifier;
  final String password;
  final String channel;

  LoginRequest({
    required this.loginIdentifier,
    required this.password,
    required this.channel,
  });

  Map<String, dynamic> toJson() => {
    'loginIdentifier': loginIdentifier,
    'password': password,
    'channel': channel,
  };
}
