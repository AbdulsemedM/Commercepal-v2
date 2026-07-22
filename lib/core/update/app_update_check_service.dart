import 'package:package_info_plus/package_info_plus.dart';

import '../logging/app_logger.dart';
import 'app_update_check_result.dart';
import 'app_update_remote_config.dart';
import 'version_parser.dart';

/// Runs the app update check using current version from [PackageInfo]
/// and latest version + store URL from [AppUpdateRemoteConfig].
class AppUpdateCheckService {
  AppUpdateCheckService._();

  /// Fetches Remote Config, then compares versions. Returns [AppUpdateCheckResult].
  /// On any error (fetch fail, parse fail), returns result with [AppUpdateType.none]
  /// so the app can proceed.
  static Future<AppUpdateCheckResult> check() async {
    try {
      await AppUpdateRemoteConfig.fetchAndActivate();
    } catch (_) {
      // Use cached config if fetch fails
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final current = packageInfo.version;
      final latest = AppUpdateRemoteConfig.latestAppVersionForCurrentPlatform;
      final storeUrl = AppUpdateRemoteConfig.storeUrlForCurrentPlatform;

      if (current.isEmpty || latest.isEmpty) {
        AppLogger.w('App update check: missing version string');
        return AppUpdateCheckResult(
          updateType: AppUpdateType.none,
          currentVersion: current,
          latestVersion: latest,
          storeUrl: storeUrl,
        );
      }

      final updateType = VersionParser.getUpdateType(current, latest);
      // debugPrint(
      //   'App update check -> current: $current, remote: $latest, type: $updateType',
      // );
      AppLogger.i(
        'App update check: current=$current latest=$latest type=$updateType',
      );

      return AppUpdateCheckResult(
        updateType: updateType,
        currentVersion: current,
        latestVersion: latest,
        storeUrl: storeUrl,
      );
    } catch (e, st) {
      AppLogger.e('App update check failed', error: e, stack: st);
      return AppUpdateCheckResult(
        updateType: AppUpdateType.none,
        currentVersion: '',
        latestVersion: '',
        storeUrl: AppUpdateRemoteConfig.storeUrlForCurrentPlatform,
      );
    }
  }
}
