import 'package:dio/dio.dart';

import '../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class DioClient {
  DioClient._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: Env.current.baseUrl,
          connectTimeout: Duration(milliseconds: Env.current.connectTimeoutMs),
          receiveTimeout: Duration(milliseconds: Env.current.receiveTimeoutMs),
          responseType: ResponseType.json,
          headers: {'Content-Type': 'application/json'},
        ),
      )..interceptors.addAll([AuthInterceptor(), LoggingInterceptor()]);

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  final Dio _dio;

  Dio get dio => _dio;
}
