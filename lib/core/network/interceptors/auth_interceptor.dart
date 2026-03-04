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
  final List<_PendingRequest> _pendingRequests = [];

  /// Do not redirect to login for these paths when session expires (show inline error instead).
  static const List<String> _noRedirectPaths = <String>[
    'recently-viewed',
  ];

  bool _shouldRedirectOnAuthFailure(RequestOptions requestOptions) {
    final path = requestOptions.path;
    return !_noRedirectPaths.any((segment) => path.contains(segment));
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
          // Redirect to login if not already on login page (skip for e.g. recently viewed)
          if (!NavigationService.instance.isOnLoginPage &&
              _shouldRedirectOnAuthFailure(requestOptions)) {
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
        if (!NavigationService.instance.isOnLoginPage &&
            _shouldRedirectOnAuthFailure(requestOptions)) {
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
}

class _PendingRequest {
  _PendingRequest(this.options, this.handler);

  final RequestOptions options;
  final ErrorInterceptorHandler handler;
}
