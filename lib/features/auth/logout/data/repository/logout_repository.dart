import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/auth/login/data/data_provider/google_sign_in_data_provider.dart';
import '../data_provider/logout_data_provider.dart';
import '../models/logout_response.dart';

class LogoutRepository {
  LogoutRepository({
    LogoutDataProvider? dataProvider, 
    GoogleSignInDataProvider? googleSignInDataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? LogoutDataProvider(),
        _googleSignInDataProvider = googleSignInDataProvider ?? GoogleSignInDataProvider(),
        _storage = storage ?? Storage();

  final LogoutDataProvider _dataProvider;
  final GoogleSignInDataProvider _googleSignInDataProvider;
  final Storage _storage;

  Future<LogoutResponse> logout() async {
    final response = await _dataProvider.logout();

    // Sign out from Google if signed in
    try {
      await _googleSignInDataProvider.signOut();
    } catch (e) {
      // Ignore Google sign out errors - user is logging out anyway
    }

    // Clear tokens from storage after successful API call
    await _storage.clearTokens();

    return response;
  }
}
