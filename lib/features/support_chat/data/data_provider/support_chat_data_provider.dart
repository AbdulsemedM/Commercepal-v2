import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/send_message_response.dart';
import '../models/support_session.dart';

class SupportChatDataProvider {
  SupportChatDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _base = '/api/v1/support/session';

  Future<SupportSession> startSession({String? initialMessage}) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '$_base/start',
        data: <String, dynamic>{
          'initialMessage': initialMessage ?? '',
        },
      );
      final data = _extractData(response);
      return SupportSession.fromJson(data);
    } on DioException catch (e) {
      AppLogger.e('startSession failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<SendMessageResponse> sendMessage({
    required String sessionToken,
    required String messageText,
    String messageType = 'TEXT',
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '$_base/$sessionToken/message',
        data: <String, dynamic>{
          'messageText': messageText,
          'messageType': messageType,
        },
      );
      final data = _extractData(response);
      return SendMessageResponse.fromJson(data);
    } on DioException catch (e) {
      AppLogger.e('sendMessage failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<SupportMessagesPage> getMessages({
    required String sessionToken,
    int afterMessageId = 0,
    String? afterId,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '$_base/$sessionToken/messages',
        query: <String, dynamic>{
          'afterMessageId': afterMessageId,
          'afterId': afterId ?? '',
        },
      );
      final data = _extractData(response);
      return SupportMessagesPage.fromJson(data);
    } on DioException catch (e) {
      AppLogger.e('getMessages failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<SupportSessionStatus> getStatus({
    required String sessionToken,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '$_base/$sessionToken/status',
      );
      final data = _extractData(response);
      return SupportSessionStatus.fromJson(data);
    } on DioException catch (e) {
      AppLogger.e('getStatus failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Map<String, dynamic> _extractData(Response<Map<String, dynamic>> response) {
    if (response.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Invalid response from server',
      );
    }
    final responseData = response.data!;
    final data = responseData['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return responseData;
  }
}
