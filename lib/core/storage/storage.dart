import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  Storage._internal();
  static final Storage _instance = Storage._internal();
  factory Storage() => _instance;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenType = 'token_type';
  static const String _keyExpiresIn = 'expires_in';
  static const String _keyUserEmail = 'user_email';

  // Token management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String tokenType = 'Bearer',
    int? expiresIn,
    String? userEmail,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      _storage.write(key: _keyTokenType, value: tokenType),
      if (expiresIn != null)
        _storage.write(key: _keyExpiresIn, value: expiresIn.toString()),
      if (userEmail != null)
        _storage.write(key: _keyUserEmail, value: userEmail),
    ]);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<String?> getTokenType() async {
    return await _storage.read(key: _keyTokenType);
  }

  Future<int?> getExpiresIn() async {
    final value = await _storage.read(key: _keyExpiresIn);
    return value != null ? int.tryParse(value) : null;
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyTokenType),
      _storage.delete(key: _keyExpiresIn),
      _storage.delete(key: _keyUserEmail),
    ]);
  }

  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Generic storage methods
  Future<void> writeData({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readData(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }
}
