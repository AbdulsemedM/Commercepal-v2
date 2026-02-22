import 'package:dio/dio.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/checkout_request.dart';
import '../models/checkout_response.dart';
import '../models/payment_retry_request.dart';

class CheckoutDataProvider {
  CheckoutDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _checkoutEndpoint = '/api/v1/orders/checkout';
  static const String _retryPaymentEndpoint = '/api/v1/payments/retry';

  Future<CheckoutResponse> checkout(CheckoutRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        _checkoutEndpoint,
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

      // Extract data from nested response structure
      final responseData = response.data!;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data != null) {
        return CheckoutResponse.fromJson(data);
      }

      // If no nested data, use response directly
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
}
