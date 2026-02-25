import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../features/products/presentation/screen/product_search_screen.dart';
import '../../features/products/bloc/product_search_bloc.dart';
import '../../features/profile/presentation/screen/terms_conditions_screen.dart';
import '../../features/profile/presentation/screen/refund_policy_screen.dart';
import '../../features/profile/presentation/screen/edit_profile_screen.dart';
import '../../features/profile/data/models/profile_data.dart';
import '../../features/orders/presentation/screen/order_history_screen.dart';
import '../../features/orders/presentation/screen/order_summary_screen.dart';
import '../../features/orders/presentation/screen/order_tracking_screen.dart';
import '../../features/orders/bloc/orders_bloc.dart';
import '../../features/orders/bloc/order_tracking_cubit.dart';
import '../../features/orders/data/models/order.dart';
import '../../features/contact_us/contact_us_page.dart';
import '../../features/addresses/presentation/screen/addresses_screen.dart';
import '../../features/addresses/bloc/address_bloc.dart';
import '../../features/checkout/presentation/screen/checkout_summary_screen.dart';
import '../../features/checkout/presentation/screen/payment_selection_screen.dart';
import '../../features/checkout/presentation/screen/payment_webview_screen.dart';
import '../../features/checkout/presentation/screen/order_placed_screen.dart';
import '../../features/checkout/presentation/screen/retry_payment_method_screen.dart';
import '../../features/checkout/data/models/checkout_response.dart';
import '../../features/affiliate_register/presentation/screen/affiliate_register_screen.dart';
import '../../features/faqs/presentation/screen/faqs_screen.dart';
import '../../features/wishlist/presentation/screen/wishlist_screen.dart';

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
  static const String productSearch = '/product-search';
  static const String termsConditions = '/terms-conditions';
  static const String refundPolicy = '/refund-policy';
  static const String editProfile = '/edit-profile';
  static const String orderHistory = '/order-history';
  static const String orderSummary = '/order-summary';
  static const String orderTracking = '/order-tracking';
  static const String contactUs = '/contact-us';
  static const String addresses = '/addresses';
  static const String checkoutSummary = '/checkout-summary';
  static const String paymentSelection = '/payment-selection';
  static const String paymentWebView = '/payment-webview';
  static const String orderPlaced = '/order-placed';
  static const String retryPaymentMethod = '/retry-payment-method';
  static const String affiliateRegister = '/affiliate-register';
  static const String faqs = '/faqs';
  static const String wishlist = '/wishlist';
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
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, String> params = state.uri.queryParameters;
        final int? initialTab = params['tab'] != null
            ? int.tryParse(params['tab']!)
            : null;
        return DashboardScreen(initialTab: initialTab);
      },
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
      path: AppRoutes.productSearch,
      name: 'productSearch',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, String> params = state.uri.queryParameters;
        return BlocProvider(
          create: (context) => ProductSearchBloc(),
          child: ProductSearchScreen(
            initialQuery: params['query'],
            providerId: params['provider'],
          ),
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
      path: AppRoutes.refundPolicy,
      name: 'refundPolicy',
      builder: (BuildContext context, GoRouterState state) =>
          const RefundPolicyScreen(),
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
      builder: (BuildContext context, GoRouterState state) => BlocProvider(
        create: (context) => OrdersBloc(),
        child: const OrderHistoryScreen(),
      ),
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
        final Order? order = state.extra is Order ? state.extra as Order : null;
        return BlocProvider(
          create: (_) => OrderTrackingCubit(),
          child: OrderTrackingScreen(
            order: order,
            orderId: params['id'],
            orderStatus: params['status'],
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.contactUs,
      name: 'contactUs',
      builder: (BuildContext context, GoRouterState state) =>
          const ContactUsPage(),
    ),
    GoRoute(
      path: AppRoutes.addresses,
      name: 'addresses',
      builder: (BuildContext context, GoRouterState state) => BlocProvider(
        create: (context) => AddressBloc(),
        child: const AddressesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.checkoutSummary,
      name: 'checkoutSummary',
      builder: (BuildContext context, GoRouterState state) =>
          const CheckoutSummaryScreen(),
    ),
    GoRoute(
      path: AppRoutes.paymentSelection,
      name: 'paymentSelection',
      builder: (BuildContext context, GoRouterState state) =>
          const PaymentSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.paymentWebView,
      name: 'paymentWebView',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final paymentUrl = extra?['paymentUrl'] as String? ?? '';
        final orderNumber = extra?['orderNumber'] as String?;
        return PaymentWebViewScreen(
          paymentUrl: paymentUrl,
          orderNumber: orderNumber,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.orderPlaced,
      name: 'orderPlaced',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final response = extra?['checkoutResponse'] as CheckoutResponse?;
        if (response == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order')),
            body: const Center(child: Text('Missing order data')),
          );
        }
        final paymentProviderCode =
            extra?['paymentProviderCode'] as String? ?? '';
        return OrderPlacedScreen(
          response: response,
          paymentProviderCode: paymentProviderCode,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.retryPaymentMethod,
      name: 'retryPaymentMethod',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final paymentReference =
            extra?['paymentReference'] as String? ?? '';
        final currency = extra?['currency'] as String? ?? '';
        final orderNumber = extra?['orderNumber'] as String?;
        return RetryPaymentMethodScreen(
          paymentReference: paymentReference,
          currency: currency,
          orderNumber: orderNumber,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.affiliateRegister,
      name: 'affiliateRegister',
      builder: (BuildContext context, GoRouterState state) {
        final onSuccess = state.extra as VoidCallback?;
        return AffiliateRegisterScreen(onRegistrationSuccess: onSuccess);
      },
    ),
    GoRoute(
      path: AppRoutes.faqs,
      name: 'faqs',
      builder: (BuildContext context, GoRouterState state) =>
          const FaqsScreen(),
    ),
    GoRoute(
      path: AppRoutes.wishlist,
      name: 'wishlist',
      builder: (BuildContext context, GoRouterState state) =>
          const WishlistScreen(),
    ),
  ],
);
