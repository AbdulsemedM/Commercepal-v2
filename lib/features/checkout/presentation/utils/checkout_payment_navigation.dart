import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../data/models/checkout_response.dart';

void _scheduleAfterNavigate(VoidCallback? onAfterNavigate) {
  if (onAfterNavigate == null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) => onAfterNavigate());
}

/// Navigates after a successful cash-on-delivery checkout.
void navigateToCashOnDeliverySuccess(
  BuildContext context,
  CheckoutResponse response, {
  VoidCallback? onAfterNavigate,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    context.go(
      AppRoutes.cashOnDeliverySuccess,
      extra: <String, dynamic>{
        'checkoutResponse': response,
      },
    );
    _scheduleAfterNavigate(onAfterNavigate);
  });
}

/// Navigates to the payment-pending confirmation screen after checkout.
void navigateToPaymentPending(
  BuildContext context,
  CheckoutResponse response, {
  VoidCallback? onAfterNavigate,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    context.go(
      AppRoutes.orderConfirmedPaymentPending,
      extra: <String, dynamic>{
        'checkoutResponse': response,
      },
    );
    _scheduleAfterNavigate(onAfterNavigate);
  });
}

/// Navigates after checkout based on [paymentInitiation.nextAction].
///
/// Deferred to the next frame so navigation does not run while the navigator
/// is locked (e.g. during setState / bloc rebuild after checkout).
void navigateAfterCheckoutSuccess(
  BuildContext context,
  CheckoutResponse response, {
  VoidCallback? onAfterNavigate,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;

    final init = response.paymentInitiation!;
    final nextAction = init.nextAction?.trim() ?? '';
    final paymentUrl = init.paymentUrl?.trim() ?? '';
    final orderNumber = response.resolvedOrderNumber;

    if (nextAction == CheckoutResponse.nextActionRedirectToPaymentUrl &&
        paymentUrl.isNotEmpty) {
      context.go(
        AppRoutes.paymentWebView,
        extra: <String, dynamic>{
          'paymentUrl': paymentUrl,
          'orderNumber': orderNumber,
        },
      );
      _scheduleAfterNavigate(onAfterNavigate);
      return;
    }

    if (nextAction == CheckoutResponse.nextActionScanQr &&
        paymentUrl.isNotEmpty) {
      context.go(
        AppRoutes.qpayQrPayment,
        extra: <String, dynamic>{
          'checkoutResponse': response,
        },
      );
      _scheduleAfterNavigate(onAfterNavigate);
      return;
    }

    if (nextAction == CheckoutResponse.nextActionOpenAdditionalInput) {
      context.go(
        AppRoutes.orderConfirmedPaymentPending,
        extra: <String, dynamic>{
          'checkoutResponse': response,
        },
      );
      _scheduleAfterNavigate(onAfterNavigate);
      return;
    }

    context.go(AppRoutes.dashboard);
    _scheduleAfterNavigate(onAfterNavigate);
  });
}

/// Navigates after a successful payment retry.
void navigateAfterRetryPaymentSuccess(
  BuildContext context,
  CheckoutResponse response,
) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;

    final init = response.paymentInitiation;
    final nextAction = init?.nextAction?.trim() ?? '';
    final paymentUrl = init?.paymentUrl?.trim() ?? '';

    if (nextAction == CheckoutResponse.nextActionScanQr &&
        paymentUrl.isNotEmpty) {
      context.go(
        AppRoutes.qpayQrPayment,
        extra: <String, dynamic>{
          'checkoutResponse': response,
        },
      );
      return;
    }

    if (nextAction == CheckoutResponse.nextActionRedirectToPaymentUrl &&
        paymentUrl.isNotEmpty) {
      context.push(
        AppRoutes.paymentWebView,
        extra: <String, dynamic>{
          'paymentUrl': paymentUrl,
          'orderNumber': response.orderNumber,
        },
      );
    }
  });
}
