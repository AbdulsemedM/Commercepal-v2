import '../data_provider/payment_status_data_provider.dart';
import '../models/payment_status_result.dart';

class PaymentStatusRepository {
  PaymentStatusRepository({PaymentStatusDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? PaymentStatusDataProvider();

  final PaymentStatusDataProvider _dataProvider;

  Future<PaymentStatusResult> getPaymentStatus(String orderNumber) {
    return _dataProvider.getPaymentStatus(orderNumber);
  }
}
