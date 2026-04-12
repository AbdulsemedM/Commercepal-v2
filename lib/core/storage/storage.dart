import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import 'package:commercepal/features/wishlist/data/wishlist_item.dart';

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

  static const _uuid = Uuid();

  // Token keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenType = 'token_type';
  static const String _keyExpiresIn = 'expires_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyDeviceId = 'device_id';
  static const String _keySelectedCountry = 'selected_country_code';
  static const String _keySelectedCurrency = 'selected_currency_code';
  static const String _keyCustomerId = 'customer_id';
  static const String _keyWishlist = 'wishlist';
  static const String _keyLocale = 'app_locale';
  static const String _keyRememberedEmail = 'remembered_email';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyHasOpenedApp = 'has_opened_app';

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
      _storage.delete(key: _keyCustomerId),
      _storage.delete(key: _keyRememberedEmail),
      _storage.delete(key: _keyBiometricEnabled),
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

  // Device ID management
  Future<String> getOrCreateDeviceId() async {
    String? deviceId = await _storage.read(key: _keyDeviceId);
    
    if (deviceId == null || deviceId.isEmpty) {
      // Generate a new device ID
      deviceId = _uuid.v4();
      await _storage.write(key: _keyDeviceId, value: deviceId);
    }
    
    return deviceId;
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(key: _keyDeviceId);
  }

  // Country and Currency management
  Future<void> saveSelectedCountry(String countryCode) async {
    await _storage.write(key: _keySelectedCountry, value: countryCode);
  }

  Future<String> getSelectedCountry() async {
    final countryCode = await _storage.read(key: _keySelectedCountry);
    return countryCode ?? 'ET'; // Default to Ethiopia
  }

  Future<void> saveSelectedCurrency(String currencyCode) async {
    await _storage.write(key: _keySelectedCurrency, value: currencyCode);
  }

  Future<String> getSelectedCurrency() async {
    final currencyCode = await _storage.read(key: _keySelectedCurrency);
    return currencyCode ?? 'ETB'; // Default to ETB (Ethiopian Birr)
  }

  // Customer ID management
  Future<void> saveCustomerId(int customerId) async {
    await _storage.write(key: _keyCustomerId, value: customerId.toString());
  }

  Future<int?> getCustomerId() async {
    final value = await _storage.read(key: _keyCustomerId);
    return value != null ? int.tryParse(value) : null;
  }

  // Wishlist management
  Future<List<WishlistItem>> getWishlist() async {
    final raw = await _storage.read(key: _keyWishlist);
    if (raw == null || raw.isEmpty) return <WishlistItem>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>?;
      if (list == null) return <WishlistItem>[];
      return list
          .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <WishlistItem>[];
    }
  }

  Future<void> addWishlistItem(WishlistItem item) async {
    final list = await getWishlist();
    if (list.any((e) => e.productId == item.productId)) return;
    list.add(item);
    await _storage.write(
      key: _keyWishlist,
      value: jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removeWishlistItem(String productId) async {
    final list = await getWishlist();
    list.removeWhere((e) => e.productId == productId);
    await _storage.write(
      key: _keyWishlist,
      value: jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<bool> isInWishlist(String productId) async {
    final list = await getWishlist();
    return list.any((e) => e.productId == productId);
  }

  /// Clear all wishlist items from local storage.
  Future<void> clearWishlist() async {
    await _storage.write(key: _keyWishlist, value: '[]');
  }

  // Locale / language
  Future<void> saveLocale(String languageCode) async {
    await _storage.write(key: _keyLocale, value: languageCode);
  }

  Future<String> getLocale() async {
    final code = await _storage.read(key: _keyLocale);
    return code ?? 'en';
  }

  // Remember me (email pre-fill)
  Future<void> saveRememberedEmail(String email) async {
    await _storage.write(key: _keyRememberedEmail, value: email);
  }

  Future<String?> getRememberedEmail() async {
    return await _storage.read(key: _keyRememberedEmail);
  }

  Future<void> clearRememberedEmail() async {
    await _storage.delete(key: _keyRememberedEmail);
  }

  // Biometric login
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _keyBiometricEnabled,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  // Cache keys for home page SWR
  static const String _keyCacheCategories = 'cache_categories';
  static const String _keyCacheRecentlyViewed = 'cache_recently_viewed';
  static const String _keyCacheHomeDiscover = 'cache_home_discover';

  Future<void> saveCachedCategories(String json) async {
    await _storage.write(key: _keyCacheCategories, value: json);
  }

  Future<String?> getCachedCategories() async {
    return await _storage.read(key: _keyCacheCategories);
  }

  Future<void> saveCachedRecentlyViewed(String json) async {
    await _storage.write(key: _keyCacheRecentlyViewed, value: json);
  }

  Future<String?> getCachedRecentlyViewed() async {
    return await _storage.read(key: _keyCacheRecentlyViewed);
  }

  Future<void> saveCachedHomeDiscover(String json) async {
    await _storage.write(key: _keyCacheHomeDiscover, value: json);
  }

  Future<String?> getCachedHomeDiscover() async {
    return await _storage.read(key: _keyCacheHomeDiscover);
  }

  /// Returns true when app has never been marked as opened.
  Future<bool> isFirstAppOpen() async {
    final value = await _storage.read(key: _keyHasOpenedApp);
    return value != 'true';
  }

  /// Marks that the app has been opened at least once.
  Future<void> markAppOpened() async {
    await _storage.write(key: _keyHasOpenedApp, value: 'true');
  }
}
