import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/payment_initiate_result.dart';
import '../models/payment_status_result.dart';

class PaymentStatusDataProvider {
  PaymentStatusDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  static const String _telebirrInitiateEndpoint =
      '/api/v1/payments/telebirr/initiate';
  static const String _edahabInitiateEndpoint =
      '/api/v1/payments/edahab/initiate';

  static const String _cbeBirrInitiateEndpoint =
      '/api/v1/payments/cbe-birr/initiate';

  Future<PaymentInitiateResult> initiateCbeBirr({
    required String orderNumber,
  }) async {
    return _initiate(
      endpoint: _cbeBirrInitiateEndpoint,
      orderNumber: orderNumber,
      label: 'CBE Birr',
    );
  }

  Future<PaymentInitiateResult> initiateTelebirr({
    required String orderNumber,
    required String phone,
  }) async {
    return _initiate(
      endpoint: _telebirrInitiateEndpoint,
      orderNumber: orderNumber,
      phone: phone,
      label: 'Telebirr',
    );
  }

  Future<PaymentInitiateResult> initiateEdahab({
    required String orderNumber,
    required String phone,
  }) async {
    return _initiate(
      endpoint: _edahabInitiateEndpoint,
      orderNumber: orderNumber,
      phone: phone,
      label: 'eDahab',
    );
  }

  Future<PaymentInitiateResult> _initiate({
    required String endpoint,
    required String orderNumber,
    required String label,
    String? phone,
  }) async {
    try {
      final Response<Map<String, dynamic>> response =
          await _apiService.post<Map<String, dynamic>>(
        endpoint,
        data: <String, dynamic>{
          'orderNumber': orderNumber,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid $label initiate response',
        );
      }
      return PaymentInitiateResult.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('$label initiate failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  Future<PaymentStatusResult> getPaymentStatus(String orderNumber) async {
    try {
      final Response<Map<String, dynamic>> response =
          await _apiService.get<Map<String, dynamic>>(
        '/api/v1/payments/order/$orderNumber/status',
      );
      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid payment status response',
        );
      }
      return PaymentStatusResult.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Payment status failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }
}
