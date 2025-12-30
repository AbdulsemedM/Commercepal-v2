class ForgotPasswordRequest {
  final String emailOrPhone;
  final String channel;

  ForgotPasswordRequest({required this.emailOrPhone, required this.channel});

  Map<String, dynamic> toJson() => {
    'emailOrPhone': emailOrPhone,
    'channel': channel,
  };
}
