import '../data_provider/affiliate_data_provider.dart';
import '../models/affiliate_dashboard_models.dart';
import '../models/affiliate_my_profile_response.dart';

class AffiliateRepository {
  AffiliateRepository({AffiliateDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? AffiliateDataProvider();

  final AffiliateDataProvider _dataProvider;

  Future<AffiliateMyProfileResponse?> getMyProfile() async {
    return _dataProvider.getMyProfile();
  }

  Future<void> registerAsCustomer({
    required String name,
    required String phoneNumber,
    required String promotionMethod,
    required String registrationChannel,
    required String deviceId,
  }) {
    return _dataProvider.registerAsCustomer(
      name: name,
      phoneNumber: phoneNumber,
      promotionMethod: promotionMethod,
      registrationChannel: registrationChannel,
      deviceId: deviceId,
    );
  }

  Future<String?> getMyReferralCode() => _dataProvider.getMyReferralCode();

  Future<AffiliateCommissionSummary?> getCommissionSummary() =>
      _dataProvider.getCommissionSummary();

  Future<AffiliateWithdrawalStats?> getWithdrawalStats() =>
      _dataProvider.getWithdrawalStats();

  Future<List<AffiliateCommission>> getCommissions() =>
      _dataProvider.getCommissions();

  Future<List<AffiliateOrderEarning>> getOrderEarnings() =>
      _dataProvider.getOrderEarnings();

  Future<List<AffiliateWithdrawal>> getMyWithdrawals() =>
      _dataProvider.getMyWithdrawals();

  Future<void> requestWithdrawal({
    required num amount,
    required AffiliatePayoutMethod method,
    required String accountNumber,
  }) {
    return _dataProvider.requestWithdrawal(
      amount: amount,
      method: method,
      accountNumber: accountNumber,
    );
  }
}
