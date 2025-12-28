import '../data_provider/change_password_data_provider.dart';
import '../models/change_password_request.dart';
import '../models/change_password_response.dart';

class ChangePasswordRepository {
  ChangePasswordRepository({ChangePasswordDataProvider? dataProvider})
    : _dataProvider = dataProvider ?? ChangePasswordDataProvider();

  final ChangePasswordDataProvider _dataProvider;

  Future<ChangePasswordResponse> changePassword(
    ChangePasswordRequest request,
  ) async {
    return await _dataProvider.changePassword(request);
  }
}
