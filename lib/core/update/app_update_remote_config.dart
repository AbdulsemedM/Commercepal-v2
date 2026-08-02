import 'dart:io' show Platform;

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../logging/app_logger.dart';
import 'app_update_constants.dart';

/// Keys for Firebase Remote Config parameters.
abstract final class RemoteConfigKeys {
  static const String latestAppVersionAndroid = 'latest_app_version_android';
  static const String latestAppVersionIos = 'latest_app_version_ios';
  static const String storeUrlAndroid = 'store_url_android';
  static const String storeUrlIos = 'store_url_ios';
  /// Optional short promo line on the home banner (empty = hidden). Set in Firebase console.
  static const String homePromoBanner = 'home_promo_banner';
  /// When non-empty, show a non-blocking maintenance/info strip (e.g. scheduled downtime).
  static const String maintenanceMessage = 'maintenance_message';
  /// Hard floor: if current app version is below this, show a blocking store update.
  /// Empty string disables the floor.
  static const String minimumSupportedVersion = 'minimum_supported_version';
  /// When true, the app skips Shorebird patch check/download (emergency lever).
  static const String killSwitchPatchDisabled = 'kill_switch_patch_disabled';
  /// Client-side staged rollout percentage (0–100) for the Shorebird beta track.
  static const String shorebirdPatchRolloutPercent =
      'shorebird_patch_rollout_percent';
}

/// Client for app version and store URLs from Firebase Remote Config.
class AppUpdateRemoteConfig {
  AppUpdateRemoteConfig._();

  static FirebaseRemoteConfig? _instance;
  static const Duration fetchTimeout = Duration(seconds: 10);

  static FirebaseRemoteConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppUpdateRemoteConfig not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  /// Call after [Firebase.initializeApp()]. Sets defaults and config settings.
  static Future<void> initialize({
    String defaultLatestVersionAndroid = '6.0.3',
    String defaultLatestVersionIos = '6.0.3',
    String? defaultStoreUrlAndroid,
    String? defaultStoreUrlIos,
  }) async {
    if (_instance != null) return;

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: fetchTimeout,
          // Fetch is only triggered at app startup (splash). This interval throttles repeated calls.
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.setDefaults(<String, dynamic>{
        RemoteConfigKeys.latestAppVersionAndroid: defaultLatestVersionAndroid,
        RemoteConfigKeys.latestAppVersionIos: defaultLatestVersionIos,
        RemoteConfigKeys.storeUrlAndroid:
            defaultStoreUrlAndroid ?? AppUpdateConstants.storeUrlAndroid,
        RemoteConfigKeys.storeUrlIos:
            defaultStoreUrlIos ?? AppUpdateConstants.storeUrlIos,
        RemoteConfigKeys.homePromoBanner: '',
        RemoteConfigKeys.maintenanceMessage: '',
        RemoteConfigKeys.minimumSupportedVersion: '',
        RemoteConfigKeys.killSwitchPatchDisabled: false,
        RemoteConfigKeys.shorebirdPatchRolloutPercent: 100,
      });
      _instance = remoteConfig;
      AppLogger.i('AppUpdateRemoteConfig initialized');
    } catch (e, st) {
      AppLogger.e(
        'AppUpdateRemoteConfig initialize failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Fetches and activates the latest config. Intended to be called once at app startup (e.g. splash).
  /// Returns true if new config was activated.
  static Future<bool> fetchAndActivate() async {
    try {
      final activated = await instance.fetchAndActivate();
      AppLogger.i('Remote Config fetchAndActivate: activated=$activated');
      return activated;
    } catch (e, st) {
      AppLogger.e('Remote Config fetchAndActivate failed', error: e, stack: st);
      return false;
    }
  }

  /// Latest required version for the current platform (Android or iOS).
  static String get latestAppVersionForCurrentPlatform {
    if (Platform.isAndroid) {
      return instance.getString(RemoteConfigKeys.latestAppVersionAndroid);
    }
    return instance.getString(RemoteConfigKeys.latestAppVersionIos);
  }

  static String get storeUrlAndroid =>
      instance.getString(RemoteConfigKeys.storeUrlAndroid).trim().isNotEmpty
          ? instance.getString(RemoteConfigKeys.storeUrlAndroid)
          : AppUpdateConstants.storeUrlAndroid;

  static String get storeUrlIos =>
      instance.getString(RemoteConfigKeys.storeUrlIos).trim().isNotEmpty
          ? instance.getString(RemoteConfigKeys.storeUrlIos)
          : AppUpdateConstants.storeUrlIos;

  /// Store URL for the current platform.
  static String get storeUrlForCurrentPlatform {
    if (Platform.isAndroid) return storeUrlAndroid;
    return storeUrlIos;
  }

  /// Remote-configurable home promo line (may be empty).
  static String get homePromoBanner =>
      instance.getString(RemoteConfigKeys.homePromoBanner).trim();

  /// Optional global notice (may be empty).
  static String get maintenanceMessage =>
      instance.getString(RemoteConfigKeys.maintenanceMessage).trim();

  /// Hard minimum store version. Empty means no floor is enforced.
  static String get minimumSupportedVersion =>
      instance.getString(RemoteConfigKeys.minimumSupportedVersion).trim();

  /// When true, Shorebird patch checks/downloads are skipped.
  static bool get killSwitchPatchDisabled {
    try {
      return instance.getBool(RemoteConfigKeys.killSwitchPatchDisabled);
    } catch (_) {
      return false;
    }
  }

  /// Percentage (0–100) of devices that should check the Shorebird beta track.
  static int get shorebirdPatchRolloutPercent {
    try {
      final int value =
          instance.getInt(RemoteConfigKeys.shorebirdPatchRolloutPercent);
      if (value < 0) return 0;
      if (value > 100) return 100;
      return value;
    } catch (_) {
      return 100;
    }
  }
}
