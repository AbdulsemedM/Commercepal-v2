import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/network/connectivity_banner_host.dart';
import '../core/update/app_update_remote_config.dart';
import '../core/update/shorebird_patch_host.dart';
import '../core/theme/theme.dart';
import '../core/theme/theme_controller.dart';
import '../core/locale/locale_controller.dart';
import '../core/locale/fallback_material_localizations.dart';
import '../core/auth/token_refresh_biometric_gate.dart';
import '../features/cart/bloc/cart_bloc.dart';
import 'router/app_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ThemeController _themeController = ThemeController();
  final LocaleController _localeController = LocaleController();
  late final CartBloc _cartBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cartBloc = CartBloc()..add(CartLoadRequested());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _themeController.loadPersistedTheme();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cartBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On iOS, [inactive] fires for transient UI (notification shade, Control
    // Center, Face ID sheet). Only clear the biometric grace window when the app
    // is actually backgrounded.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      TokenRefreshBiometricGate.instance.onAppBackgrounded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartBloc>.value(
      value: _cartBloc,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (BuildContext context, Widget? _) {
          return AnimatedBuilder(
            animation: _themeController,
            builder: (BuildContext context, Widget? __) {
              final locale = _localeController.locale;
              final isRtl = locale.languageCode == 'ar';
              return LocaleControllerScope(
                localeController: _localeController,
                child: ThemeControllerScope(
                  themeController: _themeController,
                  child: MaterialApp.router(
                routerConfig: appRouter,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: _themeController.themeMode,
                debugShowCheckedModeBanner: false,
                locale: locale,
                supportedLocales: LocaleController.supportedLocales,
                localizationsDelegates: const [
                  FallbackMaterialLocalizationsDelegate(),
                  FallbackCupertinoLocalizationsDelegate(),
                  FallbackWidgetsLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                localeResolutionCallback: (locale, supported) {
                  for (final s in supported) {
                    if (s.languageCode == locale?.languageCode) return s;
                  }
                  return const Locale('en');
                },
                builder: (context, child) {
                  String maintenance = '';
                  try {
                    maintenance = AppUpdateRemoteConfig.maintenanceMessage;
                  } catch (_) {}
                  return ShorebirdPatchHost(
                    child: Directionality(
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          ConnectivityBannerHost(child: child!),
                          if (maintenance.isNotEmpty)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SafeArea(
                                bottom: false,
                                child: Material(
                                  elevation: 3,
                                  color: Colors.deepOrange.shade50,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      maintenance,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.deepOrange.shade900,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
