import '../data_provider/checkout_data_provider.dart';
import '../models/checkout_request.dart';
import '../models/checkout_response.dart';

class CheckoutRepository {
  CheckoutRepository({CheckoutDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? CheckoutDataProvider();

  final CheckoutDataProvider _dataProvider;

  Future<CheckoutResponse> checkout(CheckoutRequest request) async {
    return await _dataProvider.checkout(request);
  }
}
