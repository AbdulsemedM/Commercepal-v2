import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../core/logging/app_logger.dart';

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      final options = headers != null && headers.isNotEmpty
          ? Options(headers: headers)
          : null;
      return await _dio.get<T>(
        path,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      AppLogger.e('GET failed: $path', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      final options = headers != null && headers.isNotEmpty
          ? Options(headers: headers)
          : null;
      return await _dio.post<T>(
        path, 
        data: data, 
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      AppLogger.e('POST failed: $path', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: query);
    } on DioException catch (e) {
      AppLogger.e('PUT failed: $path', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      final options = headers != null && headers.isNotEmpty
          ? Options(headers: headers)
          : null;
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      AppLogger.e('PATCH failed: $path', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: query);
    } on DioException catch (e) {
      AppLogger.e('DELETE failed: $path', error: e, stack: e.stackTrace);
      rethrow;
    }
  }
}
