import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/login_response.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleSignInDataProvider {
  GoogleSignInDataProvider({
    ApiService? apiService,
    GoogleSignIn? googleSignIn,
  })  : _apiService = apiService ?? ApiService(),
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: [
            'email',
            'profile',
          ],
        );

  final ApiService _apiService;
  final GoogleSignIn _googleSignIn;
  static const String _oauth2Endpoint = '/api/v1/auth/oauth2/login';

  /// Sign in with Google and authenticate with backend
  Future<LoginResponse> signInWithGoogle({String? channel, String? deviceId}) async {
    try {
      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();
      
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        throw Exception('Google Sign In was cancelled');
      }

      // Extract user information
      final String email = googleUser.email;
      final String? displayName = googleUser.displayName;
      final String providerUserId = googleUser.id;
      
      // Split display name into first and last name
      String firstName = '';
      String lastName = '';
      if (displayName != null && displayName.isNotEmpty) {
        final nameParts = displayName.trim().split(' ');
        firstName = nameParts.first;
        if (nameParts.length > 1) {
          lastName = nameParts.sublist(1).join(' ');
        }
      }

      // Send user data to backend OAuth2 endpoint
      final response = await _apiService.post<Map<String, dynamic>>(
        _oauth2Endpoint,
        data: {
          'provider': 'GOOGLE',
          'providerUserId': providerUserId,
          'email': email,
          if (firstName.isNotEmpty) 'firstName': firstName,
          if (lastName.isNotEmpty) 'lastName': lastName,
          if (deviceId != null) 'deviceId': deviceId,
          'channel': channel ?? _getDefaultChannel(),
        },
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      // Extract data from nested response structure
      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;
      
      if (data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response structure: missing data field',
        );
      }

      return LoginResponse.fromJson(data);
    } on DioException catch (e) {
      AppLogger.e('Google Sign In failed', error: e, stack: e.stackTrace);
      
      if (e.response?.statusCode == 401) {
        throw Exception('Google authentication failed. Please try again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Google Sign In is not available. Please contact support.');
      }
      
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during Google Sign In',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  /// Get default channel based on platform
  String _getDefaultChannel() {
    if (kIsWeb) {
      return 'WEB';
    } else if (Platform.isAndroid) {
      return 'ANDROID';
    } else if (Platform.isIOS) {
      return 'IOS';
    } else {
      return 'WEB';
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e, stack) {
      AppLogger.e('Google Sign Out failed', error: e, stack: stack);
      // Don't rethrow - sign out should be best effort
    }
  }

  /// Check if user is currently signed in with Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current Google user if signed in
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }
}
