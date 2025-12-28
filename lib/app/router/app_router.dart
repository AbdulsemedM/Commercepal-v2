import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login/presentation/screen/login_screen.dart';
import '../../features/auth/signup/presentation/screen/signup_screen.dart';
import '../../features/auth/forgot_password/presentation/screen/forgot_password_screen.dart';
import '../../features/auth/reset_password/presentation/screen/reset_password_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/products/presentation/screen/product_detail_screen.dart';
import '../../features/products/presentation/screen/product_details_reviews_screen.dart';
import '../../features/profile/presentation/screen/terms_conditions_screen.dart';
import '../../features/profile/presentation/screen/edit_profile_screen.dart';
import '../../features/profile/data/models/profile_data.dart';
import '../../features/orders/presentation/screen/order_history_screen.dart';
import '../../features/orders/presentation/screen/order_summary_screen.dart';
import '../../features/orders/presentation/screen/order_tracking_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String splash = '/splash';
  static const String dashboard = '/dashboard';
  static const String productDetail = '/product-detail';
  static const String productDetailsReviews = '/product-details-reviews';
  static const String termsConditions = '/terms-conditions';
  static const String editProfile = '/edit-profile';
  static const String orderHistory = '/order-history';
  static const String orderSummary = '/order-summary';
  static const String orderTracking = '/order-tracking';
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
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (BuildContext context, GoRouterState state) =>
          const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      name: 'resetPassword',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, String> params = state.uri.queryParameters;
        return ResetPasswordScreen(
          target: params['target'],
          verificationToken: params['token'],
        );
      },
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
    GoRoute(
      path: AppRoutes.productDetailsReviews,
      name: 'productDetailsReviews',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, String> params = state.uri.queryParameters;
        return ProductDetailsReviewsScreen(
          productId: params['id'],
          productName: params['name'],
        );
      },
    ),
    GoRoute(
      path: AppRoutes.termsConditions,
      name: 'termsConditions',
      builder: (BuildContext context, GoRouterState state) =>
          const TermsConditionsScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      name: 'editProfile',
      builder: (BuildContext context, GoRouterState state) {
        final profile = state.extra as ProfileData?;
        return EditProfileScreen(initialProfile: profile);
      },
    ),
    GoRoute(
      path: AppRoutes.orderHistory,
      name: 'orderHistory',
      builder: (BuildContext context, GoRouterState state) =>
          const OrderHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderSummary,
      name: 'orderSummary',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, String> params = state.uri.queryParameters;
        return OrderSummaryScreen(orderId: params['id']);
      },
    ),
    GoRoute(
      path: AppRoutes.orderTracking,
      name: 'orderTracking',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, String> params = state.uri.queryParameters;
        return OrderTrackingScreen(
          orderId: params['id'],
          orderStatus: params['status'],
        );
      },
    ),
  ],
);
