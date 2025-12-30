class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final String channel;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
    required this.channel,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
    'channel': channel,
  };
}
