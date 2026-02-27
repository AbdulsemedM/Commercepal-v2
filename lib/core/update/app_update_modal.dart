import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../widgets/app_dialog.dart';
import 'app_update_check_result.dart';

/// Shows the app update modal (optional or mandatory) and opens the store when Update is tapped.
class AppUpdateModal {
  AppUpdateModal._();

  static const String _titleOptional = 'Update available';
  static const String _titleMandatory = 'Update required';
  static const String _messageOptional =
      'A new version (%s) is available. Update now for the latest features and improvements.';
  static const String _messageMandatory =
      'Please update to version %s to continue using the app.';

  /// Shows the update modal. For [mandatory], the dialog is not dismissible (no "Later").
  /// "Update" opens [storeUrl] in the store. [onLater] is called when user taps "Later" (optional only).
  static Future<void> show(
    BuildContext context, {
    required AppUpdateCheckResult result,
    VoidCallback? onLater,
  }) {
    final bool mandatory = result.isMandatory;
    final String title =
        mandatory ? _titleMandatory : _titleOptional;
    final String messageFormatted =
        (mandatory ? _messageMandatory : _messageOptional)
            .replaceAll('%s', result.latestVersion);

    final List<AppDialogAction> actions = [
      if (!mandatory)
        AppDialogAction(
          label: 'Later',
          onPressed: () {
            onLater?.call();
          },
        ),
      AppDialogAction(
        label: 'Update',
        isPrimary: true,
        onPressed: () => _openStore(result.storeUrl),
      ),
    ];

    return AppDialog.show<void>(
      context,
      title: title,
      message: messageFormatted,
      icon: Icon(
        Icons.system_update_rounded,
        color: AppColors.primary,
        size: 40,
      ),
      actions: actions,
      isDismissible: !mandatory,
      onWillPop: mandatory ? () async => false : null,
    );
  }

  static Future<void> _openStore(String storeUrl) async {
    try {
      final uri = Uri.parse(storeUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      // Ignore; user may have no store app
    }
  }
}
