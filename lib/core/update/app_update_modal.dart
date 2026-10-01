import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/localization_service.dart';
import '../widgets/app_dialog.dart';
import 'app_update_check_result.dart';
import 'app_update_constants.dart';
import 'remote_config_value_validators.dart';

/// Shows the app update modal (optional or mandatory) and opens the store when Update is tapped.
class AppUpdateModal {
  AppUpdateModal._();

  /// Shows the update modal. For [mandatory], the dialog is not dismissible (no "Later").
  /// "Update" opens [storeUrl] in the store. [onLater] is called when user taps "Later" (optional only).
  static Future<void> show(
    BuildContext context, {
    required AppUpdateCheckResult result,
    VoidCallback? onLater,
  }) {
    final bool mandatory = result.isMandatory;
    final String title = context.tr(
      mandatory ? 'update.titleMandatory' : 'update.titleOptional',
    );
    final String messageFormatted = context.tr(
      mandatory ? 'update.messageMandatory' : 'update.messageOptional',
      <String, Object?>{'version': result.latestVersion},
    );

    final String storeUrl = result.storeUrl.trim().isNotEmpty
        ? result.storeUrl
        : _fallbackStoreUrl();

    final List<AppDialogAction> actions = [
      if (!mandatory)
        AppDialogAction(
          label: context.tr('update.later'),
          onPressed: () {
            onLater?.call();
          },
        ),
      AppDialogAction(
        label: context.tr('update.update'),
        isPrimary: true,
        onPressed: () {
          // Schedule launch after dialog closes so it runs in a valid context
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _openStore(storeUrl);
          });
        },
      ),
    ];

    return AppDialog.show<void>(
      context,
      title: title,
      message: messageFormatted,
      icon: const Icon(Icons.system_update_rounded),
      actions: actions,
      isDismissible: !mandatory,
      onWillPop: mandatory ? () async => false : null,
    );
  }

  static String _fallbackStoreUrl() {
    if (Platform.isAndroid) return AppUpdateConstants.storeUrlAndroid;
    return AppUpdateConstants.storeUrlIos;
  }

  static Future<void> _openStore(String storeUrl) async {
    final bool android = Platform.isAndroid;
    String url = storeUrl.trim().isEmpty ? _fallbackStoreUrl() : storeUrl.trim();
    if (!RemoteConfigValueValidators.isAllowedStoreUrl(url, android: android)) {
      url = _fallbackStoreUrl();
    }
    try {
      if (android) {
        // Prefer market: intent so the Play Store app opens directly
        final marketUri = Uri.parse(AppUpdateConstants.storeIntentAndroid);
        final launched =
            await _launchWithMode(marketUri, LaunchMode.externalApplication);
        if (launched) return;
      }
      final uri = Uri.parse(url);
      bool launched = await _launchWithMode(uri, LaunchMode.externalApplication);
      if (!launched) {
        launched = await _launchWithMode(uri, LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        final fallback = _fallbackStoreUrl();
        final uri = Uri.parse(fallback);
        await _launchWithMode(uri, LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  static Future<bool> _launchWithMode(Uri uri, LaunchMode mode) async {
    try {
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }
}
