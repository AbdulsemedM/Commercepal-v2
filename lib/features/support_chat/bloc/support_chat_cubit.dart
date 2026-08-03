import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/core/storage/storage.dart';
import '../data/models/support_message.dart';
import '../data/repository/support_chat_repository.dart';

part 'support_chat_state.dart';

class SupportChatCubit extends Cubit<SupportChatState> {
  SupportChatCubit({
    SupportChatRepository? repository,
    Storage? storage,
    String? initialMessage,
  })  : _repository = repository ?? SupportChatRepository(),
        _storage = storage ?? Storage(),
        _pendingInitialMessage = initialMessage,
        super(const SupportChatInitial());

  final SupportChatRepository _repository;
  final Storage _storage;
  final String? _pendingInitialMessage;

  String? _sessionToken;
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 4);

  Future<void> openChat() async {
    emit(const SupportChatLoading());
    try {
      final token = await _storage.getSupportChatToken();
      final status = await _storage.getSupportChatStatus();
      final canResume = token != null &&
          token.isNotEmpty &&
          (status == 'OPEN' || status == 'WAITING');

      if (canResume) {
        _sessionToken = token;
        final page = await _repository.getMessages(
          sessionToken: token,
          afterMessageId: 0,
        );
        String? agentName;
        if (page.status == 'WAITING' || page.status.toUpperCase() == 'ASSIGNED') {
          try {
            final st = await _repository.getStatus(sessionToken: token);
            agentName = st.agentName;
            if (st.status.toUpperCase() == 'CLOSED') {
              await _storage.clearSupportChatSession();
              _sessionToken = null;
              emit(SupportChatLoaded(
                messages: const <SupportMessage>[],
                sessionStatus: 'OPEN',
                showWelcome: true,
              ));
              await _maybeSendPendingInitial();
              _startPolling();
              return;
            }
            await _storage.saveSupportChatSession(
              token: token,
              status: st.status,
            );
          } catch (_) {}
        }
        emit(SupportChatLoaded(
          messages: page.messages,
          sessionStatus: page.status,
          onlineAgents: page.onlineAgents,
          agentName: agentName,
        ));
        _startPolling();
        await _maybeSendPendingInitial();
        return;
      }

      emit(const SupportChatLoaded(
        messages: <SupportMessage>[],
        sessionStatus: 'OPEN',
        showWelcome: true,
      ));
      await _maybeSendPendingInitial();
    } catch (e) {
      emit(SupportChatError(_stripException(e)));
    }
  }

  Future<void> _maybeSendPendingInitial() async {
    final pending = _pendingInitialMessage?.trim();
    if (pending == null || pending.isEmpty) return;
    await sendMessage(pending);
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final current = state;
    if (current is! SupportChatLoaded) return;
    if (current.isSending) return;

    final optimistic = SupportMessage(
      messageId: -DateTime.now().millisecondsSinceEpoch,
      senderType: 'CUSTOMER',
      messageText: trimmed,
      messageType: 'TEXT',
      createdAt: DateTime.now(),
    );

    emit(current.copyWith(
      isSending: true,
      messages: <SupportMessage>[...current.messages, optimistic],
      showWelcome: false,
      clearError: true,
    ));

    try {
      if (_sessionToken == null || _sessionToken!.isEmpty) {
        final session = await _repository.startSession(initialMessage: trimmed);
        _sessionToken = session.sessionToken;
        await _storage.saveSupportChatSession(
          token: session.sessionToken,
          status: session.status,
        );

        final page = await _repository.getMessages(
          sessionToken: session.sessionToken,
          afterMessageId: 0,
        );
        emit(SupportChatLoaded(
          messages: page.messages,
          sessionStatus: page.status,
          onlineAgents: page.onlineAgents,
          isSending: false,
        ));
        _startPolling();
        return;
      }

      final result = await _repository.sendMessage(
        sessionToken: _sessionToken!,
        messageText: trimmed,
      );

      final withoutOptimistic = current.messages
          .where((m) => m.messageId != optimistic.messageId)
          .toList();
      final next = <SupportMessage>[...withoutOptimistic];
      if (result.customerMessage != null) {
        next.add(result.customerMessage!);
      } else {
        next.add(optimistic.copyWith(messageId: optimistic.messageId.abs()));
      }
      if (result.aiMessage != null) {
        next.add(result.aiMessage!);
      }

      await _storage.saveSupportChatSession(
        token: _sessionToken!,
        status: result.sessionStatus,
      );

      emit(SupportChatLoaded(
        messages: _dedupeById(next),
        sessionStatus: result.sessionStatus,
        onlineAgents: current.onlineAgents,
        agentName: current.agentName,
        escalated: result.escalated || current.escalated,
        isSending: false,
      ));
    } catch (e) {
      final loaded = state;
      if (loaded is SupportChatLoaded) {
        emit(loaded.copyWith(
          isSending: false,
          messages: loaded.messages
              .where((m) => m.messageId != optimistic.messageId)
              .toList(),
          sendError: _stripException(e),
        ));
      } else {
        emit(SupportChatError(_stripException(e)));
      }
    }
  }

  Future<void> retry() async {
    await openChat();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (_sessionToken == null) return;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    final token = _sessionToken;
    if (token == null || token.isEmpty) return;
    final current = state;
    if (current is! SupportChatLoaded || current.isSending) return;

    try {
      final lastId = current.messages.isEmpty
          ? 0
          : current.messages
              .map((m) => m.messageId)
              .where((id) => id > 0)
              .fold<int>(0, (a, b) => a > b ? a : b);

      final page = await _repository.getMessages(
        sessionToken: token,
        afterMessageId: lastId,
      );

      if (page.status.toUpperCase() == 'CLOSED') {
        await _storage.clearSupportChatSession();
        _sessionToken = null;
        _pollTimer?.cancel();
      } else {
        await _storage.saveSupportChatSession(
          token: token,
          status: page.status,
        );
      }

      String? agentName = current.agentName;
      if (page.status == 'WAITING' ||
          page.status.toUpperCase() == 'ASSIGNED' ||
          current.escalated) {
        try {
          final st = await _repository.getStatus(sessionToken: token);
          agentName = st.agentName ?? agentName;
        } catch (_) {}
      }

      final merged = lastId == 0
          ? page.messages
          : _dedupeById(<SupportMessage>[
              ...current.messages,
              ...page.messages,
            ]);

      if (!isClosed) {
        emit(current.copyWith(
          messages: merged,
          sessionStatus: page.status,
          onlineAgents: page.onlineAgents ?? current.onlineAgents,
          agentName: agentName,
        ));
      }
    } catch (_) {
      // Silent poll failures; user can still send messages.
    }
  }

  List<SupportMessage> _dedupeById(List<SupportMessage> list) {
    final seen = <int>{};
    final out = <SupportMessage>[];
    for (final m in list) {
      if (m.messageId > 0 && !seen.add(m.messageId)) continue;
      if (m.messageId <= 0) {
        out.add(m);
        continue;
      }
      out.add(m);
    }
    out.sort((a, b) {
      final aId = a.messageId;
      final bId = b.messageId;
      if (aId > 0 && bId > 0) return aId.compareTo(bId);
      final aAt = a.createdAt;
      final bAt = b.createdAt;
      if (aAt != null && bAt != null) return aAt.compareTo(bAt);
      return 0;
    });
    return out;
  }

  String _stripException(Object e) {
    final s = e.toString();
    if (s.startsWith('Exception: ')) return s.substring(11);
    return s;
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}

extension on SupportMessage {
  SupportMessage copyWith({int? messageId}) {
    return SupportMessage(
      messageId: messageId ?? this.messageId,
      senderType: senderType,
      messageText: messageText,
      messageType: messageType,
      createdAt: createdAt,
    );
  }
}
