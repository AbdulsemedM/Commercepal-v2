import 'package:commercepal/core/storage/storage.dart';
import '../data_provider/login_data_provider.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class LoginRepository {
  LoginRepository({LoginDataProvider? dataProvider, Storage? storage})
    : _dataProvider = dataProvider ?? LoginDataProvider(),
      _storage = storage ?? Storage();

  final LoginDataProvider _dataProvider;
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
}
