import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/update/app_update_check_result.dart';
import 'package:commercepal/core/update/app_update_check_service.dart';
import 'package:commercepal/core/update/app_update_modal.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _runSplashAndVersionCheck();
  }

  Future<void> _runSplashAndVersionCheck() async {
    const Duration minSplashDuration = Duration(seconds: 2);

    final results = await Future.wait(<Future<dynamic>>[
      Future<void>.delayed(minSplashDuration),
      AppUpdateCheckService.check(),
    ]);

    final AppUpdateCheckResult result = results[1] as AppUpdateCheckResult;

    if (!mounted) return;

    if (result.hasUpdate) {
      await AppUpdateModal.show(
        context,
        result: result,
        onLater: () {
          if (mounted) context.go(AppRoutes.dashboard);
        },
      );
      return;
    }

    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Primary background color layer
          Container(color: Theme.of(context).primaryColor),

          // Wavy SVG background overlay
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/background.svg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Centered logo
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 220,
              fit: BoxFit.contain,
            ),
          ),

          // Bottom loading indicator
          Align(
            alignment: const Alignment(0, 0.85),
            child: SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
