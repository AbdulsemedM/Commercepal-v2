import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/affiliate_my_profile_response.dart';

class AffiliateDataProvider {
  AffiliateDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _myProfileEndpoint = '/api/v1/affiliates/my-profile';
  static const String _registerFromCustomerEndpoint =
      '/api/v1/affiliates/register/from-customer';

  Future<AffiliateMyProfileResponse?> getMyProfile() async {
    try {
      final response =
          await _apiService.get<Map<String, dynamic>>(_myProfileEndpoint);

      if (response.data == null) {
        return null;
      }

      return AffiliateMyProfileResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      AppLogger.e('Get affiliate profile failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get affiliate profile',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<void> registerFromCustomer({
    required String commissionType,
    required String referralCode,
    required String registrationChannel,
    required String deviceId,
  }) async {
    try {
      await _apiService.post<Map<String, dynamic>>(
        _registerFromCustomerEndpoint,
        data: {
          'commissionType': commissionType,
          'referralCode': referralCode,
          'registrationChannel': registrationChannel,
          'deviceId': deviceId,
        },
      );
    } on DioException catch (e) {
      AppLogger.e(
        'Register from customer failed',
        error: e,
        stack: e.stackTrace,
      );
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during register from customer',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
