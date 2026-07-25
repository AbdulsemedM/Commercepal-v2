import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';
import '../core/auth/session_error.dart';

/// Global navigation service for accessing router from anywhere
class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();

  /// Redirect to login screen
  void redirectToLogin() {
    appRouter.go(AppRoutes.login);
  }

  /// Check if current route is login
  bool get isOnLoginPage {
    try {
      return appRouter.routerDelegate.currentConfiguration.uri.path == AppRoutes.login;
    } catch (e) {
      return false;
    }
  }

  /// Returns true when [error] is an auth rejection and the user was redirected.
  bool handleSessionExpired(dynamic error) {
    if (!isUnauthorizedError(error)) {
      return false;
    }

    if (isOnLoginPage) {
      return false;
    }

    redirectToLogin();
    return true;
  }

  /// Navigate to dashboard with a specific tab using context
  void navigateToDashboardTab(BuildContext context, int tabIndex) {
    context.go('${AppRoutes.dashboard}?tab=$tabIndex');
  }
}
