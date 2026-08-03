import 'support_message.dart';

class SendMessageResponse {
  const SendMessageResponse({
    this.customerMessage,
    this.aiMessage,
    required this.sessionStatus,
    this.intentDetected,
    this.escalated = false,
  });

  final SupportMessage? customerMessage;
  final SupportMessage? aiMessage;
  final String sessionStatus;
  final String? intentDetected;
  final bool escalated;

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      customerMessage: json['customerMessage'] is Map<String, dynamic>
          ? SupportMessage.fromJson(
              json['customerMessage'] as Map<String, dynamic>,
            )
          : null,
      aiMessage: json['aiMessage'] is Map<String, dynamic>
          ? SupportMessage.fromJson(json['aiMessage'] as Map<String, dynamic>)
          : null,
      sessionStatus: json['sessionStatus']?.toString() ?? 'OPEN',
      intentDetected: json['intentDetected']?.toString(),
      escalated: json['escalated'] == true,
    );
  }
}
