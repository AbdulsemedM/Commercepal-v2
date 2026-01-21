import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

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

      emit(
        LoginSuccess(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      );
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      if (e is Exception) {
        // You can parse specific error messages from the exception here
        errorMessage =
            e.toString().contains('401') ||
                e.toString().contains('Unauthorized')
            ? 'Invalid email or password'
            : errorMessage;
      }

      emit(LoginFailure(errorMessage));
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
        channel: event.channel ?? PlatformUtils.getChannel(),
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
      String errorMessage = 'Google Sign In failed. Please try again.';

      if (e is Exception) {
        final errorString = e.toString();
        
        if (errorString.contains('cancelled') || 
            errorString.contains('canceled')) {
          errorMessage = 'Google Sign In was cancelled';
        } else if (errorString.contains('401') ||
            errorString.contains('Unauthorized')) {
          errorMessage = 'Google authentication failed';
        } else if (errorString.contains('network') ||
            errorString.contains('connection')) {
          errorMessage = 'Network error. Please check your connection.';
        }
      }

      emit(LoginFailure(errorMessage));
    }
  }

  void _onLoginReset(LoginReset event, Emitter<LoginState> emit) {
    emit(LoginInitial());
  }
}
