import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_router.dart';
import '../../data/models/checkout_response.dart';
import '../../data/models/payment_constants.dart';
import '../../data/models/payment_flow_constants.dart';
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
  VoidCallback? onPaymentSuccess,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    context.go(
      AppRoutes.cashOnDeliverySuccess,
      extra: <String, dynamic>{
        'checkoutResponse': response,
      },
    );
    _scheduleAfterNavigate(onPaymentSuccess);
  });
}

/// Navigates to the payment-pending confirmation screen after checkout.
void navigateToPaymentPending(
  BuildContext context,
  CheckoutResponse response, {
  PaymentInitiateResult? initiateResult,
  String? paymentProviderCode,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final PaymentInitiateResult? resolvedInitiate =
        initiateResult ?? _initiateFromResponse(response);
    context.go(
      AppRoutes.orderConfirmedPaymentPending,
      extra: <String, dynamic>{
        'checkoutResponse': response,
        if (resolvedInitiate != null) 'initiateResult': resolvedInitiate,
        if (paymentProviderCode != null)
          'paymentProviderCode': paymentProviderCode,
      },
    );
  });
}

PaymentInitiateResult? _initiateFromResponse(CheckoutResponse response) {
  final String? ussd = response.resolvedUssdCode;
  if (ussd != null && ussd.isNotEmpty) {
    return PaymentInitiateResult(
      ussdCode: ussd,
      paymentInstructions: response.paymentInitiation?.resolvedInstructions,
    );
  }
  return null;
}

/// Unified post-checkout router based on [nextAction] (guide §4).
Future<void> navigateAfterCheckout(
  BuildContext context, {
  required CheckoutResponse response,
  required String paymentProviderCode,
  String? paymentAccount,
  VoidCallback? onPaymentSuccess,
}) async {
  final String? orderNumber = response.resolvedOrderNumber;
  if (orderNumber == null || orderNumber.isEmpty) {
    return;
  }

  String nextAction = response.resolvedNextAction ?? '';
  String? paymentUrl = response.resolvedPaymentUrl;
  String? ussdCode = response.resolvedUssdCode;

  // Fallback: infer nextAction from response fields when missing.
  if (nextAction.isEmpty) {
    if (ussdCode != null && ussdCode.isNotEmpty) {
      nextAction = NextAction.ussdCode;
    } else if (paymentUrl != null && paymentUrl.isNotEmpty) {
      nextAction = PaymentConstants.isQPay(paymentProviderCode)
          ? NextAction.scanQr
          : NextAction.redirectToPaymentUrl;
    } else if (PaymentConstants.isCashOnDelivery(paymentProviderCode)) {
      nextAction = NextAction.success;
    } else {
      nextAction = NextAction.pending;
    }
  }

  switch (nextAction) {
    case NextAction.success:
      if (PaymentConstants.isCashOnDelivery(paymentProviderCode)) {
        navigateToCashOnDeliverySuccess(
          context,
          response,
          onPaymentSuccess: onPaymentSuccess,
        );
      } else {
        navigateToPaymentPending(
          context,
          response,
          paymentProviderCode: paymentProviderCode,
        );
      }
      return;

    case NextAction.ussdCode:
    case CheckoutResponse.nextActionOpenAdditionalInput:
      if (ussdCode == null || ussdCode.isEmpty) {
        ussdCode = await _fallbackInitiateUssd(
          paymentProviderCode: paymentProviderCode,
          orderNumber: orderNumber,
          phone: paymentAccount,
        );
      }
      if (!context.mounted) return;
      if (ussdCode != null && ussdCode.isNotEmpty) {
        await _showUssdDialog(context, ussdCode);
      }
      navigateToPaymentPending(
        context,
        response,
        initiateResult: ussdCode != null && ussdCode.isNotEmpty
            ? PaymentInitiateResult(ussdCode: ussdCode)
            : null,
        paymentProviderCode: paymentProviderCode,
      );
      return;

    case NextAction.redirectToPaymentUrl:
      if (paymentUrl == null || paymentUrl.isEmpty) {
        paymentUrl = await _fallbackInitiateRedirect(
          paymentProviderCode: paymentProviderCode,
          orderNumber: orderNumber,
        );
      }
      if (!context.mounted) return;
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        await _openPaymentUrl(
          context,
          paymentUrl: paymentUrl,
          orderNumber: orderNumber,
          paymentProviderCode: paymentProviderCode,
        );
        return;
      }
      navigateToPaymentPending(
        context,
        response,
        paymentProviderCode: paymentProviderCode,
      );
      return;

    case NextAction.scanQr:
    case NextAction.showQrCode:
      if (!context.mounted) return;
      context.go(
        AppRoutes.qpayQrPayment,
        extra: <String, dynamic>{
          'checkoutResponse': response,
        },
      );
      return;

    case NextAction.pending:
    default:
      navigateToPaymentPending(
        context,
        response,
        paymentProviderCode: paymentProviderCode,
      );
      return;
  }
}

Future<String?> _fallbackInitiateUssd({
  required String paymentProviderCode,
  required String orderNumber,
  String? phone,
}) async {
  if (phone == null || phone.isEmpty) return null;
  if (!PaymentConstants.usesDocsInitiateFlow(paymentProviderCode)) {
    return null;
  }
  try {
    final PaymentStatusRepository repository = PaymentStatusRepository();
    final PaymentInitiateResult result;
    if (PaymentConstants.isTelebirr(paymentProviderCode)) {
      result = await repository.initiateTelebirr(
        orderNumber: orderNumber,
        phone: phone,
      );
    } else {
      result = await repository.initiateEdahab(
        orderNumber: orderNumber,
        phone: phone,
      );
    }
    return result.ussdCode;
  } catch (_) {
    return null;
  }
}

Future<String?> _fallbackInitiateRedirect({
  required String paymentProviderCode,
  required String orderNumber,
}) async {
  if (!PaymentConstants.isCbeBirr(paymentProviderCode)) return null;
  try {
    final PaymentStatusRepository repository = PaymentStatusRepository();
    final PaymentInitiateResult result = await repository.initiateCbeBirr(
      orderNumber: orderNumber,
    );
    return result.paymentUrl;
  } catch (_) {
    return null;
  }
}

Future<void> _openPaymentUrl(
  BuildContext context, {
  required String paymentUrl,
  required String orderNumber,
  required String paymentProviderCode,
}) async {
  if (PaymentConstants.requiresExternalBrowser(paymentProviderCode)) {
    final Uri uri = Uri.parse(paymentUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    navigateToPaymentPending(
      context,
      CheckoutResponse(orderNumber: orderNumber),
      paymentProviderCode: paymentProviderCode,
    );
    return;
  }

  if (!context.mounted) return;
  context.go(
    AppRoutes.paymentWebView,
    extra: <String, dynamic>{
      'paymentUrl': paymentUrl,
      'orderNumber': orderNumber,
      'paymentProviderCode': paymentProviderCode,
    },
  );
}

Future<void> _showUssdDialog(BuildContext context, String ussdCode) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: const Text('Dial to Pay'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SelectableText(
            ussdCode,
            style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final Uri uri = Uri.parse('tel:${Uri.encodeComponent(ussdCode)}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            icon: const Icon(Icons.phone),
            label: const Text('Open Dialer'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Navigates after a successful payment retry.
Future<void> navigateAfterRetryPaymentSuccess(
  BuildContext context,
  CheckoutResponse response, {
  required String paymentProviderCode,
  String? paymentAccount,
}) async {
  await navigateAfterCheckout(
    context,
    response: response,
    paymentProviderCode: paymentProviderCode,
    paymentAccount: paymentAccount,
  );
}

@Deprecated('Use navigateAfterCheckout')
Future<void> navigateAfterDocsCheckout(
  BuildContext context, {
  required CheckoutResponse response,
  required dynamic paymentMethod,
  String? phone,
  VoidCallback? onAfterNavigate,
}) async {
  final String code = paymentMethod is Enum
      ? (paymentMethod as dynamic).apiValue as String
      : paymentMethod.toString();
  await navigateAfterCheckout(
    context,
    response: response,
    paymentProviderCode: code,
    paymentAccount: phone,
    onPaymentSuccess: onAfterNavigate,
  );
}

@Deprecated('Use navigateAfterCheckout')
Future<bool> tryNavigateDocsInitiateCheckout(
  BuildContext context, {
  required CheckoutResponse response,
  required String paymentProviderCode,
  required String? phone,
  VoidCallback? onAfterNavigate,
}) async {
  await navigateAfterCheckout(
    context,
    response: response,
    paymentProviderCode: paymentProviderCode,
    paymentAccount: phone,
    onPaymentSuccess: onAfterNavigate,
  );
  return true;
}

@Deprecated('Use navigateAfterCheckout')
void navigateAfterCheckoutSuccess(
  BuildContext context,
  CheckoutResponse response, {
  VoidCallback? onAfterNavigate,
}) {
  final String? provider =
      response.paymentInitiation?.paymentProviderCode ?? '';
  navigateAfterCheckout(
    context,
    response: response,
    paymentProviderCode: provider ?? '',
    onPaymentSuccess: onAfterNavigate,
  );
}
