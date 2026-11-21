import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/auth/express_checkout.dart';
import 'package:commercepal/features/checkout/express/express_checkout_sheet.dart';
import 'package:commercepal/services/auth_service.dart';

import '../data/models/cart.dart';

/// Starts checkout for [cart]: guests check out with name + phone (express
/// checkout), signing in stays available. Shared by the cart page and the
/// slide-in cart so both behave the same.
Future<void> startCartCheckout(BuildContext context, Cart cart) async {
  if (!AuthService().isLoggedIn) {
    await ExpressCheckout.instance.ensureLoaded();
    if (!context.mounted) return;
    if (!ExpressCheckout.instance.isActive) {
      final Object? result =
          await showExpressCheckoutSheet(context, currency: cart.currency);
      if (!context.mounted) return;
      if (result == 'signIn') {
        final bool? signedIn = await context.push<bool>(AppRoutes.login);
        if (!context.mounted || signedIn != true || !AuthService().isLoggedIn) {
          return;
        }
      } else if (result != true) {
        return;
      }
    }
  }
  if (!context.mounted) return;
  context.push(AppRoutes.checkoutSummary, extra: cart);
}
