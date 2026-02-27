import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/theme.dart';
import '../core/theme/theme_controller.dart';
import '../core/locale/locale_controller.dart';
import '../core/locale/fallback_material_localizations.dart';
import '../features/cart/bloc/cart_bloc.dart';
import 'router/app_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController _themeController = ThemeController(
    initialMode: ThemeMode.light,
  );
  final LocaleController _localeController = LocaleController();
  late final CartBloc _cartBloc;

  @override
  void initState() {
    super.initState();
    _cartBloc = CartBloc()..add(CartLoadRequested());
  }

  @override
  void dispose() {
    _cartBloc.close();
    super.dispose();
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
                  return Directionality(
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                    child: child!,
                  );
                },
              ),
              );
            },
          );
        },
      ),
    );
  }
}
