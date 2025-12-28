class ForgotPasswordRequest {
  final String emailOrPhone;
  final String channel;

  ForgotPasswordRequest({required this.emailOrPhone, this.channel = 'WEB'});

  Map<String, dynamic> toJson() => {
    'emailOrPhone': emailOrPhone,
    'channel': channel,
  };
}
