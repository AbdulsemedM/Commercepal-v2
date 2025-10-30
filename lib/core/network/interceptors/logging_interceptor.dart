import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../logging/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.d(
        '[REQ] ${options.method} ${options.uri}',
        data: {
          'headers': options.headers,
          'query': options.queryParameters,
          'data': options.data,
        },
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.d(
        '[RES] ${response.requestOptions.method} ${response.requestOptions.uri}',
        data: {'statusCode': response.statusCode, 'data': response.data},
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e(
      '[ERR] ${err.requestOptions.method} ${err.requestOptions.uri}',
      error: err,
      stack: err.stackTrace,
      data: {
        'statusCode': err.response?.statusCode,
        'data': err.response?.data,
      },
    );
    super.onError(err, handler);
  }
}
