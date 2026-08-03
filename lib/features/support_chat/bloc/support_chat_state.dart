part of 'support_chat_cubit.dart';

sealed class SupportChatState {
  const SupportChatState();
}

final class SupportChatInitial extends SupportChatState {
  const SupportChatInitial();
}

final class SupportChatLoading extends SupportChatState {
  const SupportChatLoading();
}

final class SupportChatLoaded extends SupportChatState {
  const SupportChatLoaded({
    required this.messages,
    required this.sessionStatus,
    this.onlineAgents,
    this.agentName,
    this.isSending = false,
    this.escalated = false,
    this.showWelcome = false,
    this.sendError,
  });

  final List<SupportMessage> messages;
  final String sessionStatus;
  final int? onlineAgents;
  final String? agentName;
  final bool isSending;
  final bool escalated;
  final bool showWelcome;
  final String? sendError;

  SupportChatLoaded copyWith({
    List<SupportMessage>? messages,
    String? sessionStatus,
    int? onlineAgents,
    String? agentName,
    bool? isSending,
    bool? escalated,
    bool? showWelcome,
    String? sendError,
    bool clearError = false,
  }) {
    return SupportChatLoaded(
      messages: messages ?? this.messages,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      onlineAgents: onlineAgents ?? this.onlineAgents,
      agentName: agentName ?? this.agentName,
      isSending: isSending ?? this.isSending,
      escalated: escalated ?? this.escalated,
      showWelcome: showWelcome ?? this.showWelcome,
      sendError: clearError ? null : (sendError ?? this.sendError),
    );
  }
}

final class SupportChatError extends SupportChatState {
  const SupportChatError(this.message);
  final String message;
}
