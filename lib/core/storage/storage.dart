import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:commercepal/core/utils/device_id_utils_io.dart'
    if (dart.library.html) 'package:commercepal/core/utils/device_id_utils_web.dart'
    as platform_device_id;
import 'package:commercepal/core/utils/install_device_id.dart';
import 'package:commercepal/features/wishlist/data/wishlist_item.dart';

class Storage {
  Storage._internal();
  static final Storage _instance = Storage._internal();
  factory Storage() => _instance;

  /// Android encryption for auth tokens and other sensitive values.
  ///
  /// Uses flutter_secure_storage v10+ custom ciphers (AES-GCM + RSA-OAEP
  /// Keystore wrap). Values are encrypted before being written to disk.
  ///
  /// Intentionally does **not** set `encryptedSharedPreferences: true`: that
  /// Jetpack Security path is deprecated in the package (removed in v11) and
  /// superseded by these ciphers. Legacy EncryptedSharedPreferences data is
  /// migrated on first access via [migrateOnAlgorithmChange].
  static const AndroidOptions androidSecureOptions = AndroidOptions(
    migrateOnAlgorithmChange: true,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    keyCipherAlgorithm:
        KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
  );

  static const _storage = FlutterSecureStorage(
    aOptions: androidSecureOptions,
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
  static const String _keyAuthChannel = 'auth_channel';
  static const String _keyUserEmail = 'user_email';
  static const String _keyDeviceId = 'device_id';
  static const String _keySelectedCountry = 'selected_country_code';
  static const String _keySelectedCurrency = 'selected_currency_code';
  static const String _keyCustomerId = 'customer_id';
  static const String _keyWishlist = 'wishlist';
  static const String _keyPriceAlerts = 'price_alerts';
  static const String _keyLocale = 'app_locale';
  static const String _keyRememberedEmail = 'remembered_email';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyHasOpenedApp = 'has_opened_app';
  static const String _keyRecentProductSearches = 'recent_product_searches';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyLocalRecentProductViews = 'local_recent_product_views';
  static const String _keyProductCompareIds = 'product_compare_ids';
  static const String _keyDashboardCoachmarksDone = 'dashboard_coachmarks_v1_done';
  static const String _keyRememberedPasswordCipher = 'remembered_password_cipher';
  static const String _keyRememberMeDeviceId = 'remember_me_device_id';
  static const String _keyRememberMeSecret = 'remember_me_secret';
  static const String _keyJustLoggedOut = 'just_logged_out';
  static const String _keyProfileCache = 'profile_cache_v1';
  static const String _keyShorebirdRolloutGroup = 'shorebird_rollout_group';
  static const String _keySupportChatToken = 'support_chat_token';
  static const String _keySupportChatStatus = 'support_chat_status';
  static const String _keySupportChatFabDx = 'support_chat_fab_dx';
  static const String _keySupportChatFabDy = 'support_chat_fab_dy';

  static const int _maxRecentProductSearches = 12;
  static const int _maxLocalRecentProductViews = 24;
  static const int _maxProductCompareIds = 4;

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

  Future<void> saveAuthChannel(String channel) async {
    await _storage.write(key: _keyAuthChannel, value: channel);
  }

  Future<String?> getAuthChannel() async {
    return await _storage.read(key: _keyAuthChannel);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// Clears access/refresh tokens and session-scoped user id. Does not remove
  /// remembered login, biometric preference, device id, or encrypted credentials.
  Future<void> clearAuthSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyTokenType),
      _storage.delete(key: _keyExpiresIn),
      _storage.delete(key: _keyAuthChannel),
      _storage.delete(key: _keyUserEmail),
      _storage.delete(key: _keyCustomerId),
      _storage.delete(key: _keyProfileCache),
    ]);
  }

  /// Same as [clearAuthSession] (legacy name).
  Future<void> clearTokens() async {
    await clearAuthSession();
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

  /// Install-scoped soft identifier for guest session, FCM, and API metadata.
  ///
  /// Prefer an already-persisted value, then a platform-supported ID
  /// (ANDROID_ID / IDFV), else a UUID v4 generated **once** and stored.
  ///
  /// This is **not** hardware attestation or an authentication control. It
  /// resets when app data is cleared or the app is reinstalled. Server-side
  /// device binding (when required) should be managed by the backend after
  /// authentication.
  Future<String> getOrCreateDeviceId() async {
    final String? persisted = await _storage.read(key: _keyDeviceId);
    if (persisted != null && persisted.trim().isNotEmpty) {
      return persisted.trim();
    }

    final String? platformId =
        await platform_device_id.tryGetPlatformDeviceId();
    final String deviceId = resolveInstallDeviceId(
      persisted: null,
      platformId: platformId,
      fallbackUuid: _uuid.v4(),
    );
    await _storage.write(key: _keyDeviceId, value: deviceId);
    return deviceId;
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(key: _keyDeviceId);
  }

  /// Random 32-byte key material for remember-me AES-GCM (base64).
  ///
  /// Separate from [getOrCreateDeviceId] so a client device ID is not used
  /// as a cryptographic security control (CWE-330 / device-identity bypass).
  Future<Uint8List> getOrCreateRememberMeKey() async {
    final String? existing = await _storage.read(key: _keyRememberMeSecret);
    if (existing != null && existing.isNotEmpty) {
      return Uint8List.fromList(base64Decode(existing));
    }
    final Random random = Random.secure();
    final Uint8List bytes =
        Uint8List.fromList(List<int>.generate(32, (_) => random.nextInt(256)));
    await _storage.write(
      key: _keyRememberMeSecret,
      value: base64Encode(bytes),
    );
    return bytes;
  }

  /// Stable 1–100 cohort used for Shorebird percentage-based patch rollouts.
  Future<int> getOrCreateShorebirdRolloutGroup() async {
    final String? raw = await _storage.read(key: _keyShorebirdRolloutGroup);
    final int? existing = int.tryParse(raw ?? '');
    if (existing != null && existing >= 1 && existing <= 100) {
      return existing;
    }

    final int group =
        1 + DateTime.now().microsecondsSinceEpoch.remainder(100);
    await _storage.write(
      key: _keyShorebirdRolloutGroup,
      value: group.toString(),
    );
    return group;
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

  /// Cached profile JSON (profile + optional affiliate). Cleared with auth session.
  Future<void> saveProfileCacheJson(String json) async {
    await _storage.write(key: _keyProfileCache, value: json);
  }

  Future<String?> getProfileCacheJson() async {
    return await _storage.read(key: _keyProfileCache);
  }

  Future<void> clearProfileCache() async {
    await _storage.delete(key: _keyProfileCache);
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

  Future<Map<String, double>> _getPriceAlertsMap() async {
    final String? raw = await _storage.read(key: _keyPriceAlerts);
    if (raw == null || raw.isEmpty) return <String, double>{};
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return <String, double>{};
      return decoded.map(
        (String key, dynamic value) =>
            MapEntry(key, (value as num).toDouble()),
      );
    } catch (_) {
      return <String, double>{};
    }
  }

  Future<void> _savePriceAlertsMap(Map<String, double> map) async {
    await _storage.write(key: _keyPriceAlerts, value: jsonEncode(map));
  }

  Future<double?> getPriceAlertTarget(String productId) async {
    final Map<String, double> map = await _getPriceAlertsMap();
    return map[productId];
  }

  Future<void> savePriceAlertTarget(String productId, double targetPrice) async {
    final Map<String, double> map = await _getPriceAlertsMap();
    map[productId] = targetPrice;
    await _savePriceAlertsMap(map);
  }

  Future<void> removePriceAlertTarget(String productId) async {
    final Map<String, double> map = await _getPriceAlertsMap();
    map.remove(productId);
    await _savePriceAlertsMap(map);
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

  /// Encrypted password blob (AES-GCM concatenation, base64).
  ///
  /// Key material lives in [_keyRememberMeSecret] (Keychain/Keystore-scoped),
  /// not a client device UUID.
  Future<void> saveRememberedPasswordCipher({
    required String cipherBase64,
  }) async {
    await _storage.write(key: _keyRememberedPasswordCipher, value: cipherBase64);
    // Drop legacy device-id binding from older installs.
    await _storage.delete(key: _keyRememberMeDeviceId);
  }

  Future<String?> getRememberedPasswordCipher() async {
    return await _storage.read(key: _keyRememberedPasswordCipher);
  }

  Future<void> clearRememberMeCredentials() async {
    await Future.wait([
      _storage.delete(key: _keyRememberedPasswordCipher),
      _storage.delete(key: _keyRememberMeDeviceId),
      _storage.delete(key: _keyRememberMeSecret),
    ]);
  }

  Future<void> setJustLoggedOut(bool value) async {
    if (value) {
      await _storage.write(key: _keyJustLoggedOut, value: 'true');
    } else {
      await _storage.delete(key: _keyJustLoggedOut);
    }
  }

  Future<bool> getJustLoggedOut() async {
    return await _storage.read(key: _keyJustLoggedOut) == 'true';
  }

  /// Last text queries used on the product search screen (newest first).
  Future<List<String>> getRecentProductSearches() async {
    final String? raw = await _storage.read(key: _keyRecentProductSearches);
    if (raw == null || raw.isEmpty) return <String>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) {
        return decoded
            .map((dynamic e) => e.toString().trim())
            .where((String s) => s.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // ignore corrupt payload
    }
    return <String>[];
  }

  Future<void> recordRecentProductSearch(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return;
    List<String> list = await getRecentProductSearches();
    list = list
        .where(
          (String s) => s.toLowerCase() != trimmed.toLowerCase(),
        )
        .toList();
    list.insert(0, trimmed);
    if (list.length > _maxRecentProductSearches) {
      list = list.sublist(0, _maxRecentProductSearches);
    }
    await _storage.write(
      key: _keyRecentProductSearches,
      value: jsonEncode(list),
    );
  }

  Future<void> removeRecentProductSearch(String query) async {
    final List<String> list = await getRecentProductSearches();
    final filtered = list
        .where(
          (String s) => s.toLowerCase() != query.toLowerCase(),
        )
        .toList();
    if (filtered.isEmpty) {
      await _storage.delete(key: _keyRecentProductSearches);
    } else {
      await _storage.write(
        key: _keyRecentProductSearches,
        value: jsonEncode(filtered),
      );
    }
  }

  Future<void> clearRecentProductSearches() async {
    await _storage.delete(key: _keyRecentProductSearches);
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
  static const String _keyCacheHomeWholesale = 'cache_home_wholesale';
  static const String _keyHomeCatalogMode = 'home_catalog_mode';

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

  Future<void> saveCachedHomeWholesale(String json) async {
    await _storage.write(key: _keyCacheHomeWholesale, value: json);
  }

  Future<String?> getCachedHomeWholesale() async {
    return await _storage.read(key: _keyCacheHomeWholesale);
  }

  Future<void> saveHomeCatalogMode(String mode) async {
    await _storage.write(key: _keyHomeCatalogMode, value: mode);
  }

  Future<String?> getHomeCatalogMode() async {
    return await _storage.read(key: _keyHomeCatalogMode);
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

  // Theme preference: `light`, `dark`, or `system`.
  Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: _keyThemeMode, value: mode);
  }

  Future<String> getThemeMode() async {
    final v = await _storage.read(key: _keyThemeMode);
    return (v == null || v.isEmpty) ? 'light' : v;
  }

  /// Locally viewed products (client-only), newest first.
  Future<List<Map<String, dynamic>>> getLocalRecentProductViews() async {
    final raw = await _storage.read(key: _keyLocalRecentProductViews);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return <Map<String, dynamic>>[];
      return decoded
          .map((dynamic e) => e is Map<String, dynamic> ? e : null)
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> clearLocalRecentProductViews() async {
    await _storage.delete(key: _keyLocalRecentProductViews);
  }

  Future<void> recordLocalProductView(Map<String, dynamic> entry) async {
    final id = entry['productId']?.toString() ?? '';
    if (id.isEmpty) return;
    var list = await getLocalRecentProductViews();
    list = list
        .where((Map<String, dynamic> e) => e['productId']?.toString() != id)
        .toList();
    list.insert(0, entry);
    if (list.length > _maxLocalRecentProductViews) {
      list = list.sublist(0, _maxLocalRecentProductViews);
    }
    await _storage.write(
      key: _keyLocalRecentProductViews,
      value: jsonEncode(list),
    );
  }

  Future<List<String>> getProductCompareIds() async {
    final raw = await _storage.read(key: _keyProductCompareIds);
    if (raw == null || raw.isEmpty) return <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return <String>[];
      return decoded
          .map((dynamic e) => e.toString())
          .where((String s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> setProductCompareIds(List<String> ids) async {
    final unique = <String>[];
    for (final id in ids) {
      final t = id.trim();
      if (t.isEmpty || unique.contains(t)) continue;
      unique.add(t);
      if (unique.length >= _maxProductCompareIds) break;
    }
    await _storage.write(key: _keyProductCompareIds, value: jsonEncode(unique));
  }

  Future<void> addProductCompareId(String productId) async {
    final id = productId.trim();
    if (id.isEmpty) return;
    final list = await getProductCompareIds();
    final next = <String>[id, ...list.where((String e) => e != id)];
    await setProductCompareIds(next);
  }

  Future<void> removeProductCompareId(String productId) async {
    final list =
        (await getProductCompareIds()).where((e) => e != productId).toList();
    await _storage.write(key: _keyProductCompareIds, value: jsonEncode(list));
  }

  Future<bool> isDashboardCoachmarksDone() async {
    return await _storage.read(key: _keyDashboardCoachmarksDone) == 'true';
  }

  Future<void> setDashboardCoachmarksDone() async {
    await _storage.write(key: _keyDashboardCoachmarksDone, value: 'true');
  }

  // Support chat session
  Future<void> saveSupportChatSession({
    required String token,
    required String status,
  }) async {
    await Future.wait([
      _storage.write(key: _keySupportChatToken, value: token),
      _storage.write(key: _keySupportChatStatus, value: status),
    ]);
  }

  Future<String?> getSupportChatToken() async {
    return await _storage.read(key: _keySupportChatToken);
  }

  Future<String?> getSupportChatStatus() async {
    return await _storage.read(key: _keySupportChatStatus);
  }

  Future<void> clearSupportChatSession() async {
    await Future.wait([
      _storage.delete(key: _keySupportChatToken),
      _storage.delete(key: _keySupportChatStatus),
    ]);
  }

  // Support chat FAB position
  Future<void> saveSupportChatFabOffset(double dx, double dy) async {
    await Future.wait([
      _storage.write(key: _keySupportChatFabDx, value: dx.toString()),
      _storage.write(key: _keySupportChatFabDy, value: dy.toString()),
    ]);
  }

  Future<(double, double)?> getSupportChatFabOffset() async {
    final dxRaw = await _storage.read(key: _keySupportChatFabDx);
    final dyRaw = await _storage.read(key: _keySupportChatFabDy);
    final dx = double.tryParse(dxRaw ?? '');
    final dy = double.tryParse(dyRaw ?? '');
    if (dx == null || dy == null) return null;
    return (dx, dy);
  }
}
