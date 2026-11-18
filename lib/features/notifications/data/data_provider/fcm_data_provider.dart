import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/fcm_register_request.dart';
import '../models/fcm_unregister_request.dart';

/// Registers the device token with the FCM v1 notification service on
/// api.commercepal.com (order confirmations, campaigns, cart reminders).
///
/// The old `/api/fcm/token/*` endpoints do not exist on the backend; calling
/// them made every registration "fail", so the token was never cached and was
/// re-sent on every launch.
class FcmDataProvider {
  FcmDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _v1RegisterUrl =
      'https://api.commercepal.com/api/v1/notifications/fcm/register';
  static const String _v1UnregisterUrl =
      'https://api.commercepal.com/api/v1/notifications/fcm/unregister';

  /// Each backend is attempted independently; rethrows if either failed so the
  /// caller does not cache the token as registered and retries later.
  Future<void> register(FcmRegisterRequest request) {
    final Map<String, dynamic> body = request.toJson();
    return _sendToAll('register', <Future<void> Function()>[
      () => _apiService.post<dynamic>(_v1RegisterUrl, data: body),
    ]);
  }

  Future<void> unregister(FcmUnregisterRequest request) {
    final Map<String, dynamic> body = request.toJson();
    return _sendToAll('unregister', <Future<void> Function()>[
      () => _apiService.delete<dynamic>(_v1UnregisterUrl, data: body),
    ]);
  }

  Future<void> _sendToAll(
    String action,
    List<Future<void> Function()> calls,
  ) async {
    Object? firstError;
    StackTrace? firstStack;
    await Future.wait(
      calls.map((Future<void> Function() call) async {
        try {
          await call();
        } on DioException catch (e) {
          AppLogger.e('FCM $action failed', error: e, stack: e.stackTrace);
          firstError ??= e;
          firstStack ??= e.stackTrace;
        } catch (e, stack) {
          AppLogger.e(
            'Unexpected error during FCM $action',
            error: e,
            stack: stack,
          );
          firstError ??= e;
          firstStack ??= stack;
        }
      }),
    );
    if (firstError != null) {
      Error.throwWithStackTrace(firstError!, firstStack ?? StackTrace.current);
    }
  }
}
