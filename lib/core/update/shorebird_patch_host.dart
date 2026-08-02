import 'dart:async';

import 'package:flutter/material.dart';

import 'shorebird_patch_service.dart';

/// Runs silent Shorebird patch checks and shows a dismissible snackbar when a
/// patch has been downloaded (applies on next natural restart).
class ShorebirdPatchHost extends StatefulWidget {
  const ShorebirdPatchHost({super.key, required this.child});

  final Widget child;

  @override
  State<ShorebirdPatchHost> createState() => _ShorebirdPatchHostState();
}

class _ShorebirdPatchHostState extends State<ShorebirdPatchHost>
    with WidgetsBindingObserver {
  bool _snackbarShownForDownload = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runCheck(force: true));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_runCheck());
    }
  }

  Future<void> _runCheck({bool force = false}) async {
    final ShorebirdPatchStatus status =
        await ShorebirdPatchService.checkAndDownloadSilently(force: force);
    if (!mounted) return;
    if (status == ShorebirdPatchStatus.downloaded &&
        !_snackbarShownForDownload) {
      _snackbarShownForDownload = true;
      _showDownloadedSnackbar();
    }
  }

  void _showDownloadedSnackbar() {
    final ScaffoldMessengerState? messenger =
        ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'An update will apply next time you open the app',
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: messenger.hideCurrentSnackBar,
        ),
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
