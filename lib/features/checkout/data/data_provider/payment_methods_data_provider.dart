import 'package:dio/dio.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/utils/platform_utils.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/payment_methods_response.dart';
import '../models/public_payment_method.dart';

class PaymentMethodsDataProvider {
  PaymentMethodsDataProvider({ApiService? apiService, Storage? storage})
      : _apiService = apiService ?? ApiService(),
        _storage = storage ?? Storage();

  final ApiService _apiService;
  final Storage _storage;
  static const String _legacyEndpoint = '/api/v1/payment-methods';
  static const String _publicEndpoint = '/api/v1/public/payment-methods';

  Future<Map<String, String>> _localeQueryParams() async {
    final String country = await _storage.getSelectedCountry();
    final String currency = await _storage.getSelectedCurrency();
    return <String, String>{
      'country': country,
      'currency': currency,
      'channel': PlatformUtils.getChannel(),
    };
  }

  /// Guide endpoint: flat list of providers.
  Future<List<PublicPaymentMethod>> getPublicPaymentMethods() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        _publicEndpoint,
        query: await _localeQueryParams(),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      final List<dynamic> dataJson =
          response.data!['data'] as List<dynamic>? ?? <dynamic>[];
      return dataJson
          .map(
            (dynamic item) => PublicPaymentMethod.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      AppLogger.e(
        'Get public payment methods failed',
        error: e,
        stack: e.stackTrace,
      );
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get public payment methods',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  /// Legacy nested categories endpoint (fallback).
  Future<PaymentMethodsResponse> getPaymentMethods() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        _legacyEndpoint,
      );

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
