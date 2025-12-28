import '../data_provider/profile_data_provider.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';

class ProfileRepository {
  ProfileRepository({ProfileDataProvider? dataProvider})
    : _dataProvider = dataProvider ?? ProfileDataProvider();

  final ProfileDataProvider _dataProvider;

  Future<ProfileResponse> getProfile() async {
    return await _dataProvider.getProfile();
  }

  Future<ProfileResponse> updateProfile(UpdateProfileRequest request) async {
    return await _dataProvider.updateProfile(request);
  }
}
