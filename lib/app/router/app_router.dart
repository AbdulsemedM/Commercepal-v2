import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login/presentation/screen/login_screen.dart';
import '../../features/auth/signup/presentation/screen/signup_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/products/presentation/screen/product_detail_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String splash = '/splash';
  static const String dashboard = '/dashboard';
  static const String productDetail = '/product-detail';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (BuildContext context, GoRouterState state) =>
          const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (BuildContext context, GoRouterState state) =>
          const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      name: 'productDetail',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, String> params = state.uri.queryParameters;
        return ProductDetailScreen(
          productId: params['id'],
          productName: params['name'],
          productPrice: params['price'],
        );
      },
    ),
  ],
);
