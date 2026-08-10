import 'package:dio/dio.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/checkout_request.dart';
import '../models/checkout_response.dart';
import '../models/payment_retry_request.dart';
import '../models/sahay_verification_result.dart';

class CheckoutDataProvider {
  CheckoutDataProvider({ApiService? apiService, Storage? storage})
      : _apiService = apiService ?? ApiService(),
        _storage = storage ?? Storage();

  final ApiService _apiService;
  final Storage _storage;
  static const String _checkoutEndpoint = '/api/v1/orders/checkout';
  static const String _sahayCheckEndpoint = '/api/v1/payments/sahay/check';
  static const String _sahayCustomerLookupEndpoint =
      '/api/v1/payments/sahaypay/customer-lookup';

  Future<CheckoutResponse> checkout(CheckoutRequest request) async {
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

  /// Retry a failed payment for an existing order.
  Future<CheckoutResponse> retryPayment({
    required String orderNumber,
    required PaymentRetryRequest request,
  }) async {
    final String path =
        '/api/v1/orders/${Uri.encodeComponent(orderNumber)}/retry-payment';
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        path,
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

  /// SahayPay registration check (guide path) with fallback to customer lookup.
  Future<SahayVerificationResult> verifySahayAccount(String phoneNumber) async {
    final normalized = _normalizeSahayPhone(phoneNumber);
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        _sahayCheckEndpoint,
        query: <String, dynamic>{'phone': '+$normalized'},
      );
      if (response.data != null) {
        return SahayVerificationResult.fromJson(
          Map<String, dynamic>.from(response.data!),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) {
        AppLogger.w('Sahay check endpoint failed, trying customer lookup');
      }
    }

    return _verifySahayCustomerLookup(normalized);
  }

  Future<SahayVerificationResult> _verifySahayCustomerLookup(
    String normalized,
  ) async {
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

      return SahayVerificationResult.fromJson(
        Map<String, dynamic>.from(response.data!),
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
