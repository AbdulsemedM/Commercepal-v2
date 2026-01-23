class CheckoutResponse {
  final String? orderId;
  final String? status;
  final String? message;
  final Map<String, dynamic>? data;

  CheckoutResponse({
    this.orderId,
    this.status,
    this.message,
    this.data,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderId: json['orderId'] as String?,
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
