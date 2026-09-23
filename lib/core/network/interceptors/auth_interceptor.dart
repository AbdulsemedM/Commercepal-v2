import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:commercepal/core/network/auth_request_options.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/utils/single_flight.dart';
import 'package:commercepal/features/auth/refresh/data/repository/refresh_token_repository.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/notification_service.dart';

/// Thrown when the backend authoritatively rejected the stored credentials, as
/// opposed to a refresh that failed for a transient reason.
class SessionRejected implements Exception {
  const SessionRejected();
}

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

  /// Prevents re-entrant session rejection while best-effort FCM unregister runs.
  bool _rejectingSession = false;

  /// Refresh slightly before the real expiry so a token cannot lapse while a
  /// request is in flight, and to absorb small device clock skew.
  static const Duration _expiryLeeway = Duration(minutes: 5);

  /// Marks a request that has already been retried once after a refresh, so a
  /// persistently rejecting endpoint cannot loop.
  static const String _retriedFlag = 'authInterceptorRetried';

  /// Every concurrent caller awaits the same refresh, so the rotating refresh
  /// token is only ever spent once.
  final SingleFlight _refresh = SingleFlight();

  /// Do not redirect to login for these paths when session expires (show inline error instead).
  static const List<String> _noRedirectPaths = <String>[
    'recently-viewed',
  ];

  bool _shouldNotifyOnAuthFailure(RequestOptions requestOptions) {
    final path = requestOptions.path;
    return !_noRedirectPaths.any((segment) => path.contains(segment));
  }

  Future<bool> _canNotifyOnAuthFailure(RequestOptions requestOptions) async {
    if (!_shouldNotifyOnAuthFailure(requestOptions)) {
      return false;
    }

    // Never notify on the very first app open (user hasn't logged in yet).
    final isFirstAppOpen = await _storage.isFirstAppOpen();
    if (isFirstAppOpen) {
      return false;
    }

    return true;
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
    // Skip adding token for public endpoints.
    final isPublicCategories =
        options.path.contains('/api/categories') &&
        !options.path.contains('/subcategories');
    final isPublicCustomerRegister =
        options.path.contains('/api/customers/register');
    if (isPublicCategories || isPublicCustomerRegister) {
      return super.onRequest(options, handler);
    }

    if (options.extra[kForceGuestSessionExtra] == true) {
      options.headers.remove('Authorization');
      options.headers['X-Session-Id'] = await _storage.getOrCreateDeviceId();
      return super.onRequest(options, handler);
    }

    var accessToken = await _storage.getAccessToken();

    // Proactively refresh expired access token when refresh token exists.
    if (_isTokenExpired(accessToken)) {
      try {
        await _refreshTokenIfNeeded(options);
      } catch (_) {
        // A genuine rejection already cleared the session and notified. Any
        // other failure (offline, timeout) leaves
        // the stored credentials alone so the next request can try again.
      }
      accessToken = await _storage.getAccessToken();
    }

    final bool hasAccessToken =
        accessToken != null && accessToken.isNotEmpty;
    final bool includeGuestSession =
        options.extra[kIncludeGuestSessionExtra] == true;

    // Web cart: guests use X-Session-Id; logged-in cart uses Bearer only unless
    // merging a guest cart (includeGuestSession).
    if (shouldAttachGuestSessionId(
      hasAccessToken: hasAccessToken,
      includeGuestSession: includeGuestSession,
      forceGuestSession: false,
    )) {
      options.headers['X-Session-Id'] = await _storage.getOrCreateDeviceId();
    } else {
      options.headers.remove('X-Session-Id');
    }

    if (hasAccessToken) {
      final tokenType = await _storage.getTokenType() ?? 'Bearer';
      options.headers['Authorization'] = '$tokenType $accessToken';
    } else {
      options.headers.remove('Authorization');
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    final requestOptions = err.requestOptions;

    // Skip refresh for auth endpoints to avoid infinite loops
    if (requestOptions.path.contains('/auth/login') ||
        requestOptions.path.contains('/auth/logout') ||
        requestOptions.path.contains('/auth/refresh')) {
      return super.onError(err, handler);
    }

    // Cart matches the website fetch client: refresh + guest fallback live
    // in CartDataProvider so this interceptor must not consume the 401.
    if (isCartGuestFallbackRoute(requestOptions.path)) {
      return super.onError(err, handler);
    }

    if (_dio == null) {
      return super.onError(err, handler);
    }

    if (requestOptions.extra[_retriedFlag] == true) {
      await _rejectSession(requestOptions, usedRefreshToken: null);
      return super.onError(err, handler);
    }

    try {
      await _refreshTokenIfNeeded(requestOptions);
    } catch (_) {
      return super.onError(err, handler);
    }

    final accessToken = await _storage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return super.onError(err, handler);
    }

    final tokenType = await _storage.getTokenType() ?? 'Bearer';
    requestOptions.headers['Authorization'] = '$tokenType $accessToken';
    requestOptions.extra[_retriedFlag] = true;

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) {
        await _rejectSession(requestOptions, usedRefreshToken: null);
      }
      super.onError(retryError, handler);
    } catch (_) {
      super.onError(err, handler);
    }
  }

  /// Collapses concurrent refresh attempts into one network call. Without this
  /// every parallel request would spend the same rotating refresh token, and
  /// the losers would be told their session expired.
  Future<void> _refreshTokenIfNeeded(RequestOptions options) {
    return _refresh.run(() => _performRefresh(options));
  }

  Future<void> _performRefresh(RequestOptions options) async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      // Only surface an expiry while an access token is still stored. Once the
      // session has been cleared the user is simply signed out, and every
      // later request would otherwise raise the same notice again.
      final accessToken = await _storage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        await _rejectSession(options, usedRefreshToken: null);
      }
      throw const SessionRejected();
    }

    try {
      await _refreshTokenRepo.refreshToken(refreshToken);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _rejectSession(options, usedRefreshToken: refreshToken);
        throw const SessionRejected();
      }
      rethrow;
    }
  }

  /// Clears credentials and tells the UI the session is gone. Skipped when the
  /// stored refresh token is no longer the rejected one, because that means a
  /// concurrent refresh already stored a newer valid pair.
  Future<void> _rejectSession(
    RequestOptions options, {
    required String? usedRefreshToken,
  }) async {
    if (_rejectingSession) return;

    if (usedRefreshToken != null) {
      final current = await _storage.getRefreshToken();
      if (current != null && current.isNotEmpty && current != usedRefreshToken) {
        return;
      }
    }

    _rejectingSession = true;
    try {
      // Best-effort: auth may already be invalid; local FCM cache is cleared either way.
      await NotificationService().unregisterTokenFromBackend();
      await _storage.clearAuthSession();
      if (await _canNotifyOnAuthFailure(options)) {
        AuthService().invalidateSession();
      }
    } finally {
      _rejectingSession = false;
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
    return DateTime.now().add(_expiryLeeway).isAfter(expiryTime);
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
