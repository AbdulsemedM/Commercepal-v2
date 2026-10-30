import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/affiliate_dashboard_models.dart';
import '../models/affiliate_my_profile_response.dart';

/// Affiliate endpoints, matching the commercepal.com `/affiliate` page.
///
/// Dashboard reads swallow errors (returning null / empty) like the web so one
/// failing card never blanks the whole dashboard.
class AffiliateDataProvider {
  AffiliateDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _myProfileEndpoint = '/api/affiliates/my-profile';
  static const String _registerAsCustomerEndpoint =
      '/api/affiliate/register-as-customer';
  static const String _registerFromCustomerEndpoint =
      '/api/affiliates/register/from-customer';
  static const String _myReferralCodeEndpoint =
      '/api/affiliate/my-referral-code';
  // Backend spelling ("commisions") is intentional.
  static const String _commissionSummaryEndpoint =
      '/api/affiliates/commisions/summary';
  static const String _commissionsEndpoint = '/api/affiliates/commisions';
  static const String _orderEarningsEndpoint =
      '/api/affiliates/commisions/order-earnings';
  static const String _myWithdrawalsEndpoint =
      '/api/affiliate/withdrawals/my-withdrawals';
  static const String _withdrawalStatsEndpoint =
      '/api/affiliate/withdrawals/stats';
  static const String _requestWithdrawalEndpoint =
      '/api/affiliate/withdrawals/request';

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

  /// Turns the signed-in customer into an affiliate. Tries the current
  /// endpoint first and falls back to the legacy one when it 404s (as web).
  Future<void> registerAsCustomer({
    required String name,
    required String phoneNumber,
    required String promotionMethod,
    required String registrationChannel,
    required String deviceId,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'name': name.trim(),
      'phoneNumber': phoneNumber,
      'promotionMethod': promotionMethod,
      'registrationChannel': registrationChannel,
      'deviceId': deviceId,
    };
    try {
      try {
        await _apiService.post<Map<String, dynamic>>(
          _registerAsCustomerEndpoint,
          data: body,
        );
        return;
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
      }
      await _apiService.post<Map<String, dynamic>>(
        _registerFromCustomerEndpoint,
        data: body,
      );
    } on DioException catch (e) {
      AppLogger.e(
        'Affiliate register-as-customer failed',
        error: e,
        stack: e.stackTrace,
      );
      rethrow;
    }
  }

  Future<String?> getMyReferralCode() async {
    final Object? data = await _getData(_myReferralCodeEndpoint);
    if (data is! Map) return null;
    final String code = '${data['referralCode'] ?? ''}'.trim();
    return code.isEmpty ? null : code;
  }

  Future<AffiliateCommissionSummary?> getCommissionSummary() async {
    final Object? data = await _getData(_commissionSummaryEndpoint);
    return data is Map<String, dynamic>
        ? AffiliateCommissionSummary.fromJson(data)
        : null;
  }

  Future<AffiliateWithdrawalStats?> getWithdrawalStats() async {
    final Object? data = await _getData(_withdrawalStatsEndpoint);
    return data is Map<String, dynamic>
        ? AffiliateWithdrawalStats.fromJson(data)
        : null;
  }

  Future<List<AffiliateCommission>> getCommissions() async {
    final List<Map<String, dynamic>> rows = await _getList(
      _commissionsEndpoint,
      <String, dynamic>{'page': 0, 'size': 50},
    );
    return rows.map(AffiliateCommission.fromJson).toList();
  }

  Future<List<AffiliateOrderEarning>> getOrderEarnings() async {
    final List<Map<String, dynamic>> rows = await _getList(
      _orderEarningsEndpoint,
      <String, dynamic>{'page': 0, 'size': 50},
    );
    return rows.map(AffiliateOrderEarning.fromJson).toList();
  }

  Future<List<AffiliateWithdrawal>> getMyWithdrawals() async {
    final List<Map<String, dynamic>> rows = await _getList(
      _myWithdrawalsEndpoint,
      <String, dynamic>{
        'page': 0,
        'size': 20,
        'sortBy': 'requestedAt',
        'sortDirection': 'DESC',
      },
    );
    return rows.map(AffiliateWithdrawal.fromJson).toList();
  }

  Future<void> requestWithdrawal({
    required num amount,
    required AffiliatePayoutMethod method,
    required String accountNumber,
  }) async {
    // Same mapping as web: CBE is a BANK payout, SahayPay goes as OTHER.
    final String paymentMethod = switch (method) {
      AffiliatePayoutMethod.telebirr => 'TELEBIRR',
      AffiliatePayoutMethod.cbe => 'BANK',
      AffiliatePayoutMethod.sahayPay => 'OTHER',
    };
    try {
      await _apiService.post<Map<String, dynamic>>(
        _requestWithdrawalEndpoint,
        data: <String, dynamic>{
          'amount': amount,
          'paymentMethod': paymentMethod,
          'accountNumber': accountNumber.trim(),
          if (method == AffiliatePayoutMethod.cbe) 'bankName': 'CBE',
          if (method == AffiliatePayoutMethod.sahayPay) 'notes': 'SahayPay',
        },
      );
    } on DioException catch (e) {
      AppLogger.e('Affiliate withdrawal failed', error: e, stack: e.stackTrace);
      rethrow;
    }
  }

  /// GET [path] and unwrap the `{data: ...}` envelope; null on any failure.
  Future<Object?> _getData(String path, [Map<String, dynamic>? query]) async {
    try {
      final response = await _apiService.get<dynamic>(
        path,
        query: query,
      );
      final Object? body = response.data;
      if (body is Map && body.containsKey('data')) return body['data'];
      return body;
    } catch (e) {
      AppLogger.w('Affiliate GET $path failed', data: e);
      return null;
    }
  }

  /// List payloads arrive bare, or paged under `content` / `items`.
  Future<List<Map<String, dynamic>>> _getList(
    String path,
    Map<String, dynamic> query,
  ) async {
    final Object? data = await _getData(path, query);
    final Object? list = data is Map ? (data['content'] ?? data['items']) : data;
    if (list is! List) return <Map<String, dynamic>>[];
    return list.whereType<Map<String, dynamic>>().toList();
  }
}
