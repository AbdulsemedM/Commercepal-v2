import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/features/affiliate/data/models/affiliate_dashboard_models.dart';
import 'package:commercepal/features/affiliate/data/models/affiliate_profile_data.dart';
import 'package:commercepal/features/affiliate/data/repository/affiliate_repository.dart';

/// Builds the public share link the web uses: `https://commercepal.com?ref=CODE`.
String affiliateReferralLink(String code) =>
    'https://commercepal.com?ref=${Uri.encodeComponent(code.trim())}';

class AffiliateDashboardState {
  const AffiliateDashboardState({
    this.loading = true,
    this.loaded = false,
    this.profile,
    this.referralCode = '',
    this.totalEarned = 0,
    this.availableBalance = 0,
    this.reserved = 0,
    this.withdrawn = 0,
    this.totalOrders = 0,
    this.earnings = const <AffiliateOrderEarning>[],
    this.withdrawals = const <AffiliateWithdrawal>[],
  });

  final bool loading;

  /// True once the first load finished (stats show "…" before that).
  final bool loaded;

  /// Null when the signed-in customer is not an affiliate yet.
  final AffiliateProfileData? profile;
  final String referralCode;
  final num totalEarned;
  final num availableBalance;

  /// Held for pending/approved withdrawal requests.
  final num reserved;
  final num withdrawn;
  final int totalOrders;
  final List<AffiliateOrderEarning> earnings;
  final List<AffiliateWithdrawal> withdrawals;

  bool get isAffiliate => profile != null;

  String get referralLink =>
      referralCode.isEmpty ? '' : affiliateReferralLink(referralCode);
}

class AffiliateDashboardCubit extends Cubit<AffiliateDashboardState> {
  AffiliateDashboardCubit({AffiliateRepository? repository})
      : _repository = repository ?? AffiliateRepository(),
        super(const AffiliateDashboardState());

  final AffiliateRepository _repository;

  /// Loads everything in parallel; the numbers follow the web dashboard.
  Future<void> load() async {
    emit(_copy(loading: true));

    AffiliateProfileData? profile;
    try {
      profile = (await _repository.getMyProfile())?.data;
    } catch (_) {
      profile = null;
    }
    if (profile == null) {
      emit(const AffiliateDashboardState(loading: false, loaded: true));
      return;
    }

    final List<Object?> r = await Future.wait<Object?>(<Future<Object?>>[
      _repository.getCommissionSummary(),
      _repository.getWithdrawalStats(),
      _repository.getCommissions(),
      _repository.getOrderEarnings(),
      _repository.getMyWithdrawals(),
      if (profile.referralCode.isEmpty) _repository.getMyReferralCode(),
    ]);
    final AffiliateCommissionSummary? summary =
        r[0] as AffiliateCommissionSummary?;
    final AffiliateWithdrawalStats? stats = r[1] as AffiliateWithdrawalStats?;
    final List<AffiliateCommission> commissions =
        r[2]! as List<AffiliateCommission>;
    final List<AffiliateOrderEarning> earnings =
        r[3]! as List<AffiliateOrderEarning>;
    final List<AffiliateWithdrawal> withdrawals =
        r[4]! as List<AffiliateWithdrawal>;
    final String code = profile.referralCode.isNotEmpty
        ? profile.referralCode
        : (r.length > 5 ? r[5] as String? : null) ?? '';

    final num reserved =
        (stats?.pendingAmount ?? 0) + (stats?.approvedAmount ?? 0);
    final num remaining = summary?.remainingAmount ?? 0;
    final int orderCommissions = commissions
        .where((AffiliateCommission c) => c.commissionType == 'ORDER')
        .length;

    emit(
      AffiliateDashboardState(
        loading: false,
        loaded: true,
        profile: profile,
        referralCode: code,
        totalEarned: summary?.totalEarned ?? 0,
        reserved: reserved,
        availableBalance: math.max(0, remaining - reserved),
        withdrawn: stats?.paidAmount ?? summary?.totalPayout ?? 0,
        totalOrders: earnings.isNotEmpty ? earnings.length : orderCommissions,
        earnings: earnings,
        withdrawals: withdrawals,
      ),
    );
  }

  /// Returns an error message, or null on success (then reloads).
  Future<String?> requestWithdrawal({
    required num amount,
    required AffiliatePayoutMethod method,
    required String accountNumber,
  }) async {
    try {
      await _repository.requestWithdrawal(
        amount: amount,
        method: method,
        accountNumber: accountNumber,
      );
    } catch (e) {
      return apiErrorMessage(e) ?? '';
    }
    await load();
    return null;
  }

  AffiliateDashboardState _copy({required bool loading}) =>
      AffiliateDashboardState(
        loading: loading,
        loaded: state.loaded,
        profile: state.profile,
        referralCode: state.referralCode,
        totalEarned: state.totalEarned,
        availableBalance: state.availableBalance,
        reserved: state.reserved,
        withdrawn: state.withdrawn,
        totalOrders: state.totalOrders,
        earnings: state.earnings,
        withdrawals: state.withdrawals,
      );
}

/// Backend `message` from a failed request, if any.
String? apiErrorMessage(Object e) {
  if (e is DioException) {
    final Object? data = e.response?.data;
    if (data is Map && data['message'] is String) {
      final String message = (data['message'] as String).trim();
      if (message.isNotEmpty) return message;
    }
  }
  return null;
}
