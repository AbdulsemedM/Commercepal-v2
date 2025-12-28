import 'package:commercepal/core/storage/storage.dart';
import '../data_provider/refresh_token_data_provider.dart';
import '../models/refresh_token_request.dart';
import '../models/refresh_token_response.dart';

class RefreshTokenRepository {
  RefreshTokenRepository({
    RefreshTokenDataProvider? dataProvider,
    Storage? storage,
  }) : _dataProvider = dataProvider ?? RefreshTokenDataProvider(),
       _storage = storage ?? Storage();

  final RefreshTokenDataProvider _dataProvider;
  final Storage _storage;

  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    final request = RefreshTokenRequest(refreshToken: refreshToken);
    final response = await _dataProvider.refreshToken(request);

    // Save new tokens to secure storage
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      tokenType: response.tokenType,
      expiresIn: response.expiresIn,
    );

    return response;
  }
}
