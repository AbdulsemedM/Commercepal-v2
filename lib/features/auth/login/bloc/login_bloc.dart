import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'package:commercepal/core/auth/remember_me_crypto.dart';
import 'package:commercepal/core/auth/session_error.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/auth/login/data/models/login_request.dart';
import 'package:commercepal/features/auth/login/data/repository/login_repository.dart';
import 'package:commercepal/services/auth_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    LoginRepository? repository, 
    AuthService? authService,
    Storage? storage,
  })  : _repository = repository ?? LoginRepository(),
      _authService = authService ?? AuthService(),
        _storage = storage ?? Storage(),
      super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LoginReset>(_onLoginReset);
  }

  final LoginRepository _repository;
  final AuthService _authService;
  final Storage _storage;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final request = LoginRequest(
        loginIdentifier: event.loginIdentifier,
        password: event.password,
        channel: event.channel ?? PlatformUtils.getChannel(),
      );

      final response = await _repository.login(request);

      // Update auth service with login state
      _authService.login(userEmail: event.loginIdentifier);

      if (event.rememberMe) {
        await _storage.saveRememberedEmail(event.loginIdentifier);
        final String? cipher = await RememberMeCrypto.encryptPassword(
          _storage,
          event.password,
        );
        if (cipher != null) {
          final String deviceId = await _storage.getOrCreateDeviceId();
          await _storage.saveRememberedPasswordCipher(
            cipherBase64: cipher,
            boundDeviceId: deviceId,
          );
        }
      } else {
        await _storage.clearRememberedEmail();
        await _storage.clearRememberMeCredentials();
      }

      emit(
        LoginSuccess(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      );
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';
      var isInvalidCredentials = false;

      if (e is Exception) {
        if (isUnauthorizedError(e)) {
          isInvalidCredentials = true;
          errorMessage = event.usedPhoneLogin
              ? 'Invalid phone number or password'
              : 'Invalid email or password';
        }
      }

      emit(
        LoginFailure(
          errorMessage,
          isInvalidCredentials: isInvalidCredentials,
          usedPhoneLogin: event.usedPhoneLogin,
        ),
      );
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      // Get or create device ID
      final deviceId = await _storage.getOrCreateDeviceId();
      
      final result = await _repository.signInWithGoogle(
        channel: event.channel ?? PlatformUtils.getGoogleSignInChannel(),
        deviceId: deviceId,
      );

      final response = result['response'];
      
      // Update auth service with login state
      _authService.login(
        userName: result['userName'] as String?,
        userEmail: result['userEmail'] as String?,
        userImageUrl: result['userImageUrl'] as String?,
      );

      emit(
        LoginSuccess(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      );
    } catch (e) {
      emit(LoginFailure(_googleSignInErrorMessage(e)));
    }
  }

  String _googleSignInErrorMessage(Object error) {
    if (error is PlatformException) {
      if (error.code == 'sign_in_failed' &&
          (error.message?.contains('ApiException: 10') ?? false)) {
        return 'Google Sign-In is not configured for this build. '
            'Please contact support.';
      }
    }

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final serverMessage = _extractServerMessage(error.response?.data);
      if (statusCode != null && statusCode >= 500) {
        return serverMessage ??
            'Google Sign In is temporarily unavailable. Please try again.';
      }
      if (serverMessage != null && serverMessage.isNotEmpty) {
        return serverMessage;
      }
    }

    if (error is Exception) {
      final errorString = error.toString();

      if (errorString.contains('cancelled') ||
          errorString.contains('canceled')) {
        return 'Google Sign In was cancelled';
      }
      if (isUnauthorizedError(error)) {
        return 'Google authentication failed';
      }
      if (errorString.contains('network') ||
          errorString.contains('connection')) {
        return 'Network error. Please check your connection.';
      }

      const prefix = 'Exception: ';
      if (errorString.startsWith(prefix)) {
        return errorString.substring(prefix.length);
      }
    }

    return 'Google Sign In failed. Please try again.';
  }

  String? _extractServerMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  void _onLoginReset(LoginReset event, Emitter<LoginState> emit) {
    emit(LoginInitial());
  }
}
