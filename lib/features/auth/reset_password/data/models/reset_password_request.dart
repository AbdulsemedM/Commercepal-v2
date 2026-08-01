class ResetPasswordRequest {
  final String emailOrPhone;
  final String verificationCode;
  final String newPassword;

  ResetPasswordRequest({
    required this.emailOrPhone,
    required this.verificationCode,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'emailOrPhone': emailOrPhone,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
      };
}
