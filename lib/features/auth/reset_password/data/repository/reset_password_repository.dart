import '../data_provider/reset_password_data_provider.dart';
import '../models/reset_password_request.dart';
import '../models/reset_password_response.dart';

class ResetPasswordRepository {
  ResetPasswordRepository({ResetPasswordDataProvider? dataProvider})
    : _dataProvider = dataProvider ?? ResetPasswordDataProvider();

  final ResetPasswordDataProvider _dataProvider;

  Future<ResetPasswordResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    return await _dataProvider.resetPassword(request);
  }
}
