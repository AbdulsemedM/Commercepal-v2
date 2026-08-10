import 'package:dio/dio.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/checkout_request.dart';
import '../models/checkout_response.dart';
import '../models/payment_retry_request.dart';
import '../models/sahay_verification_result.dart';

class CheckoutDataProvider {
  CheckoutDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _checkoutEndpoint = '/api/v1/orders/checkout';
  static const String _retryPaymentEndpoint = '/api/v1/payments/retry';
  static const String _sahayCustomerLookupEndpoint =
      '/api/v1/payments/sahaypay/customer-lookup';

  Future<CheckoutResponse> checkout(CheckoutRequest request) async {
    return _postCheckout(request.toJson());
  }

  /// Not used until production accepts the docs checkout body
  /// (`cartId`, `shippingAddress`, `paymentMethod`).
  Future<CheckoutResponse> checkoutDocs(DocsCheckoutRequest request) async {
    return _postCheckout(request.toJson());
  }

  Future<CheckoutResponse> _postCheckout(Map<String, dynamic> body) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        _checkoutEndpoint,
        data: body,
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data != null) {
        return CheckoutResponse.fromJson(data);
      }

      return CheckoutResponse.fromJson(responseData);
    } on DioException catch (e) {
      AppLogger.e('Checkout failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e('Unexpected error during checkout', error: e, stack: stack);
      rethrow;
    }
  }

  /// Retry a failed payment. Returns updated checkout/order data with
  /// paymentInitiation (e.g. new paymentUrl or nextAction).
  Future<CheckoutResponse> retryPayment(PaymentRetryRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        _retryPaymentEndpoint,
        data: request.toJson(),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data != null) {
        return CheckoutResponse.fromJson(data);
      }

      return CheckoutResponse.fromJson(responseData);
    } on DioException catch (e) {
      AppLogger.e('Retry payment failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during retry payment',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  /// SahayPay customer lookup: GET with phoneNumber query (format 251 + 9 digits).
  /// Response: { status: 0, message: "string", data: { customerName: "ABDI MOHAMED" } }
  Future<SahayVerificationResult> verifySahayAccount(String phoneNumber) async {
    final normalized = _normalizeSahayPhone(phoneNumber);
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        _sahayCustomerLookupEndpoint,
        query: <String, dynamic>{'phoneNumber': normalized},
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final responseData = response.data!;
      return SahayVerificationResult.fromJson(
        Map<String, dynamic>.from(responseData),
      );
    } on DioException catch (e) {
      AppLogger.e('Sahay customer lookup failed', error: e, stack: e.stackTrace);
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'] as String?;
        if (msg != null && msg.isNotEmpty) {
          throw DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: msg,
          );
        }
      }
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during Sahay customer lookup',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  /// Normalize to 251 + 9 digits (e.g. 251912345678).
  static String _normalizeSahayPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 12 && digits.startsWith('251')) {
      return digits.substring(0, 12);
    }
    if (digits.length == 10 && digits.startsWith('0')) {
      return '251${digits.substring(1)}';
    }
    if (digits.length == 9) {
      return '251$digits';
    }
    if (digits.length >= 9) {
      return '251${digits.substring(digits.length - 9)}';
    }
    return '251$digits';
  }
}
