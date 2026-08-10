import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../data/models/checkout_request.dart';
import '../../data/models/checkout_response.dart';
import '../../data/models/payment_constants.dart';
import '../../data/models/payment_initiate_result.dart';
import '../../data/repository/payment_status_repository.dart';

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
  PaymentInitiateResult? initiateResult,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final PaymentInitiateResult? resolvedInitiate = initiateResult ??
        _initiateFromDocsResponse(response);
    context.go(
      AppRoutes.orderConfirmedPaymentPending,
      extra: <String, dynamic>{
        'checkoutResponse': response,
        if (resolvedInitiate != null) 'initiateResult': resolvedInitiate,
      },
    );
    _scheduleAfterNavigate(onAfterNavigate);
  });
}

PaymentInitiateResult? _initiateFromDocsResponse(CheckoutResponse response) {
  final String? ussd = response.ussdCode?.trim();
  if (ussd != null && ussd.isNotEmpty) {
    return PaymentInitiateResult(ussdCode: ussd);
  }
  return null;
}

/// Docs checkout: route by payment method using paymentUrl / ussdCode + optional initiate.
Future<void> navigateAfterDocsCheckout(
  BuildContext context, {
  required CheckoutResponse response,
  required DocsPaymentMethod paymentMethod,
  String? phone,
  VoidCallback? onAfterNavigate,
}) async {
  final String? orderNumber = response.resolvedOrderNumber;
  if (orderNumber == null || orderNumber.isEmpty) {
    return;
  }

  PaymentInitiateResult? initiateResult = _initiateFromDocsResponse(response);
  String? paymentUrl = response.paymentUrl?.trim();
  String? ussdCode =
      initiateResult?.ussdCode ?? response.ussdCode?.trim();

  final PaymentStatusRepository repository = PaymentStatusRepository();

  if (PaymentConstants.usesDocsUssdFlow(paymentMethod)) {
    if (ussdCode == null || ussdCode.isEmpty) {
      if (phone != null && phone.isNotEmpty) {
        try {
          if (paymentMethod == DocsPaymentMethod.telebirr) {
            initiateResult = await repository.initiateTelebirr(
              orderNumber: orderNumber,
              phone: phone,
            );
          } else {
            initiateResult = await repository.initiateEdahab(
              orderNumber: orderNumber,
              phone: phone,
            );
          }
          ussdCode = initiateResult.ussdCode;
        } catch (_) {
          // Checkout already reserved the order; show pending without initiate details.
        }
      }
    }

    if (!context.mounted) return;
    navigateToPaymentPending(
      context,
      response,
      initiateResult: initiateResult ??
          (ussdCode != null && ussdCode.isNotEmpty
              ? PaymentInitiateResult(ussdCode: ussdCode)
              : null),
      onAfterNavigate: onAfterNavigate,
    );
    return;
  }

  if (PaymentConstants.usesDocsWebViewFlow(paymentMethod)) {
    if (paymentUrl == null || paymentUrl.isEmpty) {
      if (paymentMethod == DocsPaymentMethod.cbeBirr) {
        try {
          initiateResult = await repository.initiateCbeBirr(
            orderNumber: orderNumber,
          );
          paymentUrl = initiateResult.paymentUrl;
        } catch (_) {
          // Fall through to pending screen.
        }
      }
    }

    if (!context.mounted) return;
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
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

    navigateToPaymentPending(
      context,
      response,
      initiateResult: initiateResult,
      onAfterNavigate: onAfterNavigate,
    );
  }
}

/// Telebirr / eDahab legacy path after old checkout shape.
/// Returns true when this flow handled navigation.
Future<bool> tryNavigateDocsInitiateCheckout(
  BuildContext context, {
  required CheckoutResponse response,
  required String paymentProviderCode,
  required String? phone,
  VoidCallback? onAfterNavigate,
}) async {
  if (!PaymentConstants.usesDocsInitiateFlow(paymentProviderCode)) {
    return false;
  }

  final String? orderNumber = response.resolvedOrderNumber;
  if (orderNumber == null || orderNumber.isEmpty) {
    return false;
  }
  if (phone == null || phone.isEmpty) {
    return false;
  }

  PaymentInitiateResult? initiateResult;
  try {
    final PaymentStatusRepository repository = PaymentStatusRepository();
    if (PaymentConstants.isTelebirr(paymentProviderCode)) {
      initiateResult = await repository.initiateTelebirr(
        orderNumber: orderNumber,
        phone: phone,
      );
    } else {
      initiateResult = await repository.initiateEdahab(
        orderNumber: orderNumber,
        phone: phone,
      );
    }
  } catch (_) {
    // Checkout already reserved the order; show pending without initiate details.
  }

  if (!context.mounted) return true;
  navigateToPaymentPending(
    context,
    response,
    initiateResult: initiateResult,
    onAfterNavigate: onAfterNavigate,
  );
  return true;
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
