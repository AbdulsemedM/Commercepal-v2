import 'package:commercepal/core/storage/storage.dart';
import '../data_provider/logout_data_provider.dart';
import '../models/logout_response.dart';

class LogoutRepository {
  LogoutRepository({LogoutDataProvider? dataProvider, Storage? storage})
    : _dataProvider = dataProvider ?? LogoutDataProvider(),
      _storage = storage ?? Storage();

  final LogoutDataProvider _dataProvider;
  final Storage _storage;

  Future<LogoutResponse> logout() async {
    final response = await _dataProvider.logout();

    // Clear tokens from storage after successful API call
    await _storage.clearTokens();

    return response;
  }
}
