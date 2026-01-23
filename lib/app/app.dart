import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/theme.dart';
import '../core/theme/theme_controller.dart';
import '../features/cart/bloc/cart_bloc.dart';
import 'router/app_router.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController _themeController = ThemeController(
    initialMode: ThemeMode.light,
  );
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
      ),
    );
  }
}
