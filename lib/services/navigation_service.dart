import '../app/router/app_router.dart';

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

  /// Check if error is session expired and redirect if needed
  /// Returns true if session expired, false otherwise
  bool handleSessionExpired(dynamic error) {
    final errorString = error.toString();
    final isSessionExpired = errorString.contains('401') ||
        errorString.contains('Unauthorized') ||
        errorString.contains('Session expired');

    if (isSessionExpired && !isOnLoginPage) {
      redirectToLogin();
      return true;
    }
    return false;
  }

  /// Navigate to dashboard with a specific tab
  void navigateToDashboardTab(int tabIndex) {
    appRouter.go('${AppRoutes.dashboard}?tab=$tabIndex');
  }
}
