import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/auth/refresh/data/repository/refresh_token_repository.dart';
import 'package:commercepal/services/navigation_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    Storage? storage,
    RefreshTokenRepository? refreshTokenRepository,
    Dio? dio,
  }) : _storage = storage ?? Storage(),
       _refreshTokenRepository = refreshTokenRepository,
       _dio = dio;

  final Storage _storage;
  RefreshTokenRepository? _refreshTokenRepository;
  final Dio? _dio;
  
  RefreshTokenRepository get refreshTokenRepository {
    _refreshTokenRepository ??= RefreshTokenRepository();
    return _refreshTokenRepository!;
  }
  bool _isRefreshing = false;
  Future<void>? _refreshFuture;
  final List<_PendingRequest> _pendingRequests = [];

  /// Do not redirect to login for these paths when session expires (show inline error instead).
  static const List<String> _noRedirectPaths = <String>[
    'recently-viewed',
  ];

  bool _shouldRedirectOnAuthFailure(RequestOptions requestOptions) {
    final path = requestOptions.path;
    return !_noRedirectPaths.any((segment) => path.contains(segment));
  }

  Future<bool> _canRedirectOnAuthFailure(RequestOptions requestOptions) async {
    if (!_shouldRedirectOnAuthFailure(requestOptions)) {
      return false;
    }

    // Never force login redirect on the very first app open.
    final isFirstAppOpen = await _storage.isFirstAppOpen();
    if (isFirstAppOpen) {
      return false;
    }

    return !NavigationService.instance.isOnLoginPage;
  }

  // Lazy initialization of RefreshTokenRepository to avoid circular dependency
  RefreshTokenRepository get _refreshTokenRepo {
    _refreshTokenRepository ??= RefreshTokenRepository();
    return _refreshTokenRepository!;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for categories endpoint (public endpoint)
    if (options.path.contains('/api/v1/categories') && 
        !options.path.contains('/subcategories')) {
      return super.onRequest(options, handler);
    }

    var accessToken = await _storage.getAccessToken();
    final tokenType = await _storage.getTokenType() ?? 'Bearer';

    // Proactively refresh expired access token when refresh token exists.
    if (_isTokenExpired(accessToken)) {
      await _refreshTokenIfNeeded();
      accessToken = await _storage.getAccessToken();
    }

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
          // Redirect to login if not already on login page (skip for e.g. recently viewed)
          if (await _canRedirectOnAuthFailure(requestOptions)) {
            NavigationService.instance.redirectToLogin();
          }
          return super.onError(err, handler);
        }

        // Refresh the token
        await _refreshTokenRepo.refreshToken(refreshToken);

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

        // If refresh fails, clear tokens and redirect to login
        await _storage.clearTokens();
        // Redirect to login if not already on login page (skip for e.g. recently viewed)
        if (await _canRedirectOnAuthFailure(requestOptions)) {
          NavigationService.instance.redirectToLogin();
        }
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
        final response = await _dio.request(
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

  Future<void> _refreshTokenIfNeeded() async {
    if (_isRefreshing && _refreshFuture != null) {
      return _refreshFuture;
    }

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return;
    }

    _isRefreshing = true;
    final refreshFuture = _refreshTokenRepo.refreshToken(refreshToken).then((_) {});
    _refreshFuture = refreshFuture;

    try {
      await refreshFuture;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  bool _isTokenExpired(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }

    final payload = _parseJwtPayload(token);
    if (payload == null || payload['exp'] == null) {
      return false;
    }

    final expValue = payload['exp'];
    final expSeconds = expValue is int ? expValue : int.tryParse('$expValue');
    if (expSeconds == null) {
      return false;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
    return DateTime.now().isAfter(expiryTime);
  }

  Map<String, dynamic>? _parseJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }
}

class _PendingRequest {
  _PendingRequest(this.options, this.handler);

  final RequestOptions options;
  final ErrorInterceptorHandler handler;
}
