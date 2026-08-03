import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import '../data_provider/support_chat_data_provider.dart';
import '../models/send_message_response.dart';
import '../models/support_session.dart';

class SupportChatRepository {
  SupportChatRepository({SupportChatDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? SupportChatDataProvider();

  final SupportChatDataProvider _dataProvider;

  Future<SupportSession> startSession({String? initialMessage}) async {
    AppLogger.i('SupportChatRepository.startSession');
    try {
      return await _dataProvider.startSession(initialMessage: initialMessage);
    } on DioException catch (e) {
      throw Exception(_mapError(e, 'Could not start support chat'));
    }
  }

  Future<SendMessageResponse> sendMessage({
    required String sessionToken,
    required String messageText,
  }) async {
    AppLogger.i('SupportChatRepository.sendMessage');
    try {
      return await _dataProvider.sendMessage(
        sessionToken: sessionToken,
        messageText: messageText,
      );
    } on DioException catch (e) {
      throw Exception(_mapError(e, 'Could not send message'));
    }
  }

  Future<SupportMessagesPage> getMessages({
    required String sessionToken,
    int afterMessageId = 0,
  }) async {
    try {
      return await _dataProvider.getMessages(
        sessionToken: sessionToken,
        afterMessageId: afterMessageId,
      );
    } on DioException catch (e) {
      throw Exception(_mapError(e, 'Could not load messages'));
    }
  }

  Future<SupportSessionStatus> getStatus({
    required String sessionToken,
  }) async {
    try {
      return await _dataProvider.getStatus(sessionToken: sessionToken);
    } on DioException catch (e) {
      throw Exception(_mapError(e, 'Could not load chat status'));
    }
  }

  String _mapError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return fallback;
  }
}
