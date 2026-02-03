import '../data_provider/affiliate_data_provider.dart';
import '../models/affiliate_my_profile_response.dart';

class AffiliateRepository {
  AffiliateRepository({AffiliateDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? AffiliateDataProvider();

  final AffiliateDataProvider _dataProvider;

  Future<AffiliateMyProfileResponse?> getMyProfile() async {
    return _dataProvider.getMyProfile();
  }

  Future<void> registerFromCustomer({
    required String commissionType,
    required String referralCode,
    required String registrationChannel,
    required String deviceId,
  }) async {
    return _dataProvider.registerFromCustomer(
      commissionType: commissionType,
      referralCode: referralCode,
      registrationChannel: registrationChannel,
      deviceId: deviceId,
    );
  }
}
