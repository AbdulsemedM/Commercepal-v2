import '../data_provider/signup_data_provider.dart';
import '../models/signup_request.dart';
import '../models/signup_response.dart';

class SignupRepository {
  SignupRepository({SignupDataProvider? dataProvider})
    : _dataProvider = dataProvider ?? SignupDataProvider();

  final SignupDataProvider _dataProvider;

  Future<SignupResponse> signup(SignupRequest request) async {
    return await _dataProvider.signup(request);
  }
}
