import '../data_provider/payment_status_data_provider.dart';
import '../models/payment_initiate_result.dart';
import '../models/payment_status_result.dart';

class PaymentStatusRepository {
  PaymentStatusRepository({PaymentStatusDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? PaymentStatusDataProvider();

  final PaymentStatusDataProvider _dataProvider;

  Future<PaymentInitiateResult> initiateCbeBirr({
    required String orderNumber,
  }) {
    return _dataProvider.initiateCbeBirr(orderNumber: orderNumber);
  }

  Future<PaymentInitiateResult> initiateTelebirr({
    required String orderNumber,
    required String phone,
  }) {
    return _dataProvider.initiateTelebirr(
      orderNumber: orderNumber,
      phone: phone,
    );
  }

  Future<PaymentInitiateResult> initiateEdahab({
    required String orderNumber,
    required String phone,
  }) {
    return _dataProvider.initiateEdahab(
      orderNumber: orderNumber,
      phone: phone,
    );
  }

  Future<PaymentStatusResult> getPaymentStatus(String orderNumber) {
    return _dataProvider.getPaymentStatus(orderNumber);
  }
}
