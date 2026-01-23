import 'package:dio/dio.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/payment_methods_response.dart';

class PaymentMethodsDataProvider {
  PaymentMethodsDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/payment-methods';

  Future<PaymentMethodsResponse> getPaymentMethods() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(_endpoint);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      return PaymentMethodsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Get payment methods failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get payment methods',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
