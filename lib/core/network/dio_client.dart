import 'package:dio/dio.dart';

import '../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.current.baseUrl,
        connectTimeout: Duration(milliseconds: Env.current.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: Env.current.receiveTimeoutMs),
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    // Add auth interceptor first
    _dio.interceptors.add(AuthInterceptor(dio: _dio));
    // Add logging interceptor last to log final requests/responses
    _dio.interceptors.add(LoggingInterceptor());
  }

  static DioClient? _instance;
  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
