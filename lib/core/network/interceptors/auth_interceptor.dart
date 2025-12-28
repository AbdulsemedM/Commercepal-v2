import 'package:dio/dio.dart';

import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/auth/refresh/data/repository/refresh_token_repository.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    Storage? storage,
    RefreshTokenRepository? refreshTokenRepository,
    Dio? dio,
  }) : _storage = storage ?? Storage(),
       _refreshTokenRepository =
           refreshTokenRepository ?? RefreshTokenRepository(),
       _dio = dio;

  final Storage _storage;
  final RefreshTokenRepository _refreshTokenRepository;
  final Dio? _dio;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _storage.getAccessToken();
    final tokenType = await _storage.getTokenType() ?? 'Bearer';

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = '$tokenType $accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Skip refresh for auth endpoints to avoid infinite loops
      if (requestOptions.path.contains('/auth/login') ||
          requestOptions.path.contains('/auth/logout') ||
          requestOptions.path.contains('/auth/refresh')) {
        return super.onError(err, handler);
      }

      // If already refreshing, queue this request
      if (_isRefreshing) {
        return _queueRequest(requestOptions, handler);
      }

      _isRefreshing = true;

      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _isRefreshing = false;
          _rejectPendingRequests(err);
          await _storage.clearTokens();
          return super.onError(err, handler);
        }

        // Refresh the token
        await _refreshTokenRepository.refreshToken(refreshToken);

        // Retry the original request with new token
        final opts = requestOptions;
        final accessToken = await _storage.getAccessToken();
        final tokenType = await _storage.getTokenType() ?? 'Bearer';

        opts.headers['Authorization'] = '$tokenType $accessToken';

        // Retry the original request with new token using Dio
        if (_dio != null) {
          final response = await _dio.request(
            opts.path,
            data: opts.data,
            queryParameters: opts.queryParameters,
            options: Options(method: opts.method, headers: opts.headers),
          );

          _isRefreshing = false;
          _resolvePendingRequests();
          handler.resolve(response);
        } else {
          _isRefreshing = false;
          _rejectPendingRequests(err);
          return super.onError(err, handler);
        }
      } catch (e) {
        _isRefreshing = false;
        _rejectPendingRequests(err);

        // If refresh fails, clear tokens and reject
        await _storage.clearTokens();
        return super.onError(err, handler);
      }
    } else {
      super.onError(err, handler);
    }
  }

  void _queueRequest(RequestOptions options, ErrorInterceptorHandler handler) {
    _pendingRequests.add(_PendingRequest(options, handler));
  }

  void _resolvePendingRequests() async {
    if (_dio == null) return;

    final accessToken = await _storage.getAccessToken();
    final tokenType = await _storage.getTokenType() ?? 'Bearer';

    for (final pending in _pendingRequests) {
      final opts = pending.options;
      opts.headers['Authorization'] = '$tokenType $accessToken';

      try {
        final response = await _dio!.request(
          opts.path,
          data: opts.data,
          queryParameters: opts.queryParameters,
          options: Options(method: opts.method, headers: opts.headers),
        );
        pending.handler.resolve(response);
      } catch (e) {
        pending.handler.reject(e as DioException);
      }
    }
    _pendingRequests.clear();
  }

  void _rejectPendingRequests(DioException err) {
    for (final pending in _pendingRequests) {
      pending.handler.reject(err);
    }
    _pendingRequests.clear();
  }
}

class _PendingRequest {
  _PendingRequest(this.options, this.handler);

  final RequestOptions options;
  final ErrorInterceptorHandler handler;
}
