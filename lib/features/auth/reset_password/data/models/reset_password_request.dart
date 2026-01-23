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
    required this.channel,
  });

  Map<String, dynamic> toJson() => {
    'target': target,
    'verificationToken': verificationToken,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
    'channel': channel,
  };
}
