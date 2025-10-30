import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import '../core/theme/theme_controller.dart';
import 'router/app_router.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController _themeController = ThemeController(
    initialMode: ThemeMode.light,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (BuildContext context, Widget? _) {
        return MaterialApp.router(
          routerConfig: appRouter,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeController.themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
