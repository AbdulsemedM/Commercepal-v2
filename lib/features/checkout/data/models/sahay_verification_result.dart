/// Result of Sahay customer lookup API.
/// GET /api/v1/payments/sahaypay/customer-lookup?phoneNumber=251XXXXXXXXX
/// Response: { status: 0, message: "string", data: { customerName: "ABDI MOHAMED" } }
class SahayVerificationResult {
  final bool success;
  final String? customerName;
  final String? message;

  SahayVerificationResult({
    required this.success,
    this.customerName,
    this.message,
  });

  /// Alias for customerName (used in UI that expected accountHolderName).
  String? get accountHolderName => customerName;

  factory SahayVerificationResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final status = json['status'];
    final success = status == 0;
    return SahayVerificationResult(
      success: success,
      customerName: data?['customerName'] as String?,
      message: json['message'] as String?,
    );
  }
}
