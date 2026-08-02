import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../logging/app_logger.dart';
import '../storage/storage.dart';
import 'app_update_remote_config.dart';

/// Outcome of a silent Shorebird patch check/download attempt.
enum ShorebirdPatchStatus {
  /// Shorebird updater is unavailable (e.g. not a Shorebird release build).
  unavailable,

  /// Remote Config kill-switch is on; no network check was made.
  disabled,

  /// No newer patch on the selected track.
  upToDate,

  /// A patch was downloaded and will apply on the next natural restart.
  downloaded,

  /// Check or download failed; safe to retry later.
  failed,
}

/// Background Shorebird patch checks and downloads.
///
/// Never blocks the UI. Patches apply only on the next app restart.
class ShorebirdPatchService {
  ShorebirdPatchService._();

  static final ShorebirdUpdater _updater = ShorebirdUpdater();
  static DateTime? _lastAttemptAt;
  static const Duration _debounce = Duration(minutes: 20);

  /// Silently checks for and downloads a patch when allowed.
  ///
  /// Respects [AppUpdateRemoteConfig.killSwitchPatchDisabled] and
  /// percentage rollout via the beta track. Debounced across resume cycles.
  static Future<ShorebirdPatchStatus> checkAndDownloadSilently({
    bool force = false,
  }) async {
    final DateTime now = DateTime.now();
    if (!force &&
        _lastAttemptAt != null &&
        now.difference(_lastAttemptAt!) < _debounce) {
      AppLogger.d('Shorebird patch check skipped (debounce)');
      return ShorebirdPatchStatus.upToDate;
    }
    _lastAttemptAt = now;

    try {
      bool killSwitch = false;
      try {
        killSwitch = AppUpdateRemoteConfig.killSwitchPatchDisabled;
      } catch (_) {
        // Remote Config not initialized — proceed without kill-switch.
      }
      if (killSwitch) {
        AppLogger.i('Shorebird patch check skipped (kill_switch_patch_disabled)');
        return ShorebirdPatchStatus.disabled;
      }

      final UpdateTrack track = await _resolveTrack();
      AppLogger.i('Shorebird patch check starting track=${track.name}');

      try {
        final Patch? current = await _updater.readCurrentPatch();
        AppLogger.i(
          'Shorebird current patch=${current?.number ?? 'none'}',
        );
      } catch (_) {
        // Non-fatal; continue with update check.
      }

      final UpdateStatus status = await _updater.checkForUpdate(track: track);
      AppLogger.i('Shorebird checkForUpdate status=$status track=${track.name}');

      if (status == UpdateStatus.unavailable) {
        return ShorebirdPatchStatus.unavailable;
      }
      if (status != UpdateStatus.outdated) {
        return ShorebirdPatchStatus.upToDate;
      }

      await _updater.update(track: track);
      AppLogger.i(
        'Shorebird patch downloaded; will apply on next restart '
        'track=${track.name}',
      );
      return ShorebirdPatchStatus.downloaded;
    } catch (e, st) {
      AppLogger.e('Shorebird patch check/download failed', error: e, stack: st);
      try {
        await FirebaseCrashlytics.instance.recordError(
          e,
          st,
          fatal: false,
          reason: 'shorebird_patch_download_failed',
        );
      } catch (_) {
        // Crashlytics may be unavailable in some builds.
      }
      return ShorebirdPatchStatus.failed;
    }
  }

  /// Staged rollout: cohort ≤ percent checks [UpdateTrack.beta]; others stable.
  ///
  /// At 0 or 100 everyone uses [UpdateTrack.stable] (normal production).
  /// Set percent to 1–99 while a patch is on the beta track, then promote
  /// the patch to stable and return percent to 100.
  static Future<UpdateTrack> _resolveTrack() async {
    int rolloutPercent = 100;
    try {
      rolloutPercent = AppUpdateRemoteConfig.shorebirdPatchRolloutPercent;
    } catch (_) {}

    if (rolloutPercent <= 0 || rolloutPercent >= 100) {
      return UpdateTrack.stable;
    }

    final int group = await Storage().getOrCreateShorebirdRolloutGroup();
    final UpdateTrack track =
        group <= rolloutPercent ? UpdateTrack.beta : UpdateTrack.stable;
    AppLogger.d(
      'Shorebird rollout group=$group percent=$rolloutPercent track=${track.name}',
    );
    return track;
  }
}
