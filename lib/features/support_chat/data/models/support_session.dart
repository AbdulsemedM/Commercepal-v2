import 'support_message.dart';

class SupportSession {
  const SupportSession({
    required this.sessionId,
    required this.sessionToken,
    required this.status,
    this.channel,
    this.createdAt,
  });

  final int sessionId;
  final String sessionToken;
  final String status;
  final String? channel;
  final DateTime? createdAt;

  factory SupportSession.fromJson(Map<String, dynamic> json) {
    return SupportSession(
      sessionId: (json['sessionId'] as num?)?.toInt() ?? 0,
      sessionToken: json['sessionToken']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      channel: json['channel']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class SupportMessagesPage {
  const SupportMessagesPage({
    required this.sessionId,
    required this.status,
    required this.messages,
    this.onlineAgents,
  });

  final int sessionId;
  final String status;
  final int? onlineAgents;
  final List<SupportMessage> messages;

  factory SupportMessagesPage.fromJson(Map<String, dynamic> json) {
    final raw = json['messages'];
    final List<SupportMessage> messages = <SupportMessage>[];
    if (raw is List<dynamic>) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          messages.add(SupportMessage.fromJson(item));
        }
      }
    }
    return SupportMessagesPage(
      sessionId: (json['sessionId'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'OPEN',
      onlineAgents: (json['onlineAgents'] as num?)?.toInt(),
      messages: messages,
    );
  }
}

class SupportSessionStatus {
  const SupportSessionStatus({
    required this.sessionId,
    required this.status,
    this.agentName,
  });

  final int sessionId;
  final String status;
  final String? agentName;

  factory SupportSessionStatus.fromJson(Map<String, dynamic> json) {
    return SupportSessionStatus(
      sessionId: (json['sessionId'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'OPEN',
      agentName: json['agentName']?.toString(),
    );
  }
}
