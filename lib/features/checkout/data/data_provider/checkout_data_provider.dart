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
  /// Placeholder: replace with real endpoint when API spec is provided.
  static const String _sahayVerifyEndpoint = '/api/v1/payments/sahay/verify';

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

  /// Verify Sahay phone number and account holder before checkout/retry.
  /// Placeholder endpoint/request; update when real API spec is provided.
  Future<SahayVerificationResult> verifySahayAccount(String phoneNumber) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        _sahayVerifyEndpoint,
        data: <String, dynamic>{'phoneNumber': phoneNumber},
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
      final payload = data ?? responseData;
      return SahayVerificationResult.fromJson(
        Map<String, dynamic>.from(payload as Map),
      );
    } on DioException catch (e) {
      AppLogger.e('Sahay verification failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during Sahay verification',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
