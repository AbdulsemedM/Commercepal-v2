import '../data_provider/payment_methods_data_provider.dart';
import '../models/payment_methods_response.dart';

class PaymentMethodsRepository {
  PaymentMethodsRepository({PaymentMethodsDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? PaymentMethodsDataProvider();

  final PaymentMethodsDataProvider _dataProvider;

  Future<PaymentMethodsResponse> getPaymentMethods() async {
    return await _dataProvider.getPaymentMethods();
  }
}
