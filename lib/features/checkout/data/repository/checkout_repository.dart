import 'package:commercepal/core/auth/express_checkout.dart';
import 'package:commercepal/services/auth_service.dart';

import '../data_provider/checkout_data_provider.dart';
import '../models/checkout_request.dart';
import '../models/checkout_response.dart';
import '../models/payment_retry_request.dart';
import '../models/sahay_verification_result.dart';

class CheckoutRepository {
  CheckoutRepository({CheckoutDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? CheckoutDataProvider();

  final CheckoutDataProvider _dataProvider;

  Future<CheckoutResponse> checkout(CheckoutRequest request) async {
    final CheckoutResponse response = await _dataProvider.checkout(request);
    final String? orderNumber = response.orderNumber;
    if (orderNumber != null &&
        !AuthService().isLoggedIn &&
        ExpressCheckout.instance.isActive) {
      // Lets My Orders show this order to a phone-checkout shopper.
      await ExpressCheckout.instance.rememberOrder(orderNumber);
    }
    return response;
  }

  Future<CheckoutResponse> retryPayment({
    required String orderNumber,
    required PaymentRetryRequest request,
  }) async {
    return await _dataProvider.retryPayment(
      orderNumber: orderNumber,
      request: request,
    );
  }

  /// Verify Sahay phone and account holder before checkout/retry.
  Future<SahayVerificationResult> verifySahayAccount(String phoneNumber) async {
    return await _dataProvider.verifySahayAccount(phoneNumber);
  }
}
