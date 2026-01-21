import 'package:commercepal/core/storage/storage.dart';
import '../data_provider/login_data_provider.dart';
import '../data_provider/google_sign_in_data_provider.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class LoginRepository {
  LoginRepository({
    LoginDataProvider? dataProvider, 
    GoogleSignInDataProvider? googleSignInDataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? LoginDataProvider(),
        _googleSignInDataProvider = googleSignInDataProvider ?? GoogleSignInDataProvider(),
        _storage = storage ?? Storage();

  final LoginDataProvider _dataProvider;
  final GoogleSignInDataProvider _googleSignInDataProvider;
  final Storage _storage;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dataProvider.login(request);

    // Save tokens to secure storage
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      tokenType: response.tokenType,
      expiresIn: response.expiresIn,
      userEmail: request.loginIdentifier,
    );

    return response;
  }

  Future<Map<String, dynamic>> signInWithGoogle({String? channel, String? deviceId}) async {
    final response = await _googleSignInDataProvider.signInWithGoogle(
      channel: channel,
      deviceId: deviceId,
    );

    // Get the Google user to save their email
    final googleUser = await _googleSignInDataProvider.getCurrentUser();
    
    // Save tokens to secure storage
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      tokenType: response.tokenType,
      expiresIn: response.expiresIn,
      userEmail: googleUser?.email,
    );

    // Return response with user info
    return {
      'response': response,
      'userName': googleUser?.displayName,
      'userEmail': googleUser?.email,
      'userImageUrl': googleUser?.photoUrl,
    };
  }

  Future<void> signOutFromGoogle() async {
    await _googleSignInDataProvider.signOut();
  }
}
