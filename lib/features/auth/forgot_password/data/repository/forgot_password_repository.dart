import '../data_provider/forgot_password_data_provider.dart';
import '../models/forgot_password_request.dart';
import '../models/forgot_password_response.dart';

class ForgotPasswordRepository {
  ForgotPasswordRepository({ForgotPasswordDataProvider? dataProvider})
    : _dataProvider = dataProvider ?? ForgotPasswordDataProvider();

  final ForgotPasswordDataProvider _dataProvider;

  Future<ForgotPasswordResponse> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    return await _dataProvider.forgotPassword(request);
  }
}
