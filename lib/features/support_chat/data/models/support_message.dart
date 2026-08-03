class SupportMessage {
  const SupportMessage({
    required this.messageId,
    required this.senderType,
    required this.messageText,
    required this.messageType,
    required this.createdAt,
  });

  final int messageId;
  final String senderType;
  final String messageText;
  final String messageType;
  final DateTime? createdAt;

  bool get isCustomer => senderType.toUpperCase() == 'CUSTOMER';
  bool get isAi => senderType.toUpperCase() == 'AI';
  bool get isAgent => senderType.toUpperCase() == 'AGENT';

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      messageId: (json['messageId'] as num?)?.toInt() ?? 0,
      senderType: json['senderType']?.toString() ?? 'AI',
      messageText: json['messageText']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'TEXT',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
