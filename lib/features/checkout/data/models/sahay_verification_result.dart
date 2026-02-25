/// Result of Sahay phone/account holder verification API.
/// Update request/response shape when the real API spec is provided.
class SahayVerificationResult {
  final bool success;
  final String? accountHolderName;
  final String? message;

  SahayVerificationResult({
    required this.success,
    this.accountHolderName,
    this.message,
  });

  factory SahayVerificationResult.fromJson(Map<String, dynamic> json) {
    return SahayVerificationResult(
      success: json['success'] as bool? ?? false,
      accountHolderName: json['accountHolderName'] as String?,
      message: json['message'] as String?,
    );
  }
}
