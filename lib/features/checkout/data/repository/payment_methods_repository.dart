import '../data_provider/payment_methods_data_provider.dart';
import '../models/payment_constants.dart';
import '../models/payment_method.dart';
import '../models/payment_method_item.dart';
import '../models/payment_methods_response.dart';

class PaymentMethodsRepository {
  PaymentMethodsRepository({PaymentMethodsDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? PaymentMethodsDataProvider();

  final PaymentMethodsDataProvider _dataProvider;

  Future<PaymentMethodsResponse> getPaymentMethods() async {
    final response = await _dataProvider.getPaymentMethods();
    return PaymentMethodsResponse(
      status: response.status,
      message: response.message,
      data: response.data
          .where((m) => !PaymentConstants.isHiddenPaymentProvider(m.code))
          .map(_withoutHiddenItems)
          .toList(),
    );
  }

  PaymentMethod _withoutHiddenItems(PaymentMethod method) {
    return PaymentMethod(
      displayName: method.displayName,
      code: method.code,
      iconUrl: method.iconUrl,
      paymentMethodItemResponses: method.paymentMethodItemResponses
          .where((item) =>
              !PaymentConstants.isHiddenPaymentProvider(item.itemCode))
          .map(_withoutHiddenVariants)
          .toList(),
    );
  }

  PaymentMethodItem _withoutHiddenVariants(PaymentMethodItem item) {
    if (item.paymentMethodItemResponses.isEmpty) return item;

    return PaymentMethodItem(
      displayName: item.displayName,
      itemCode: item.itemCode,
      currency: item.currency,
      iconUrl: item.iconUrl,
      paymentInstruction: item.paymentInstruction,
      requireAccountNumberOnInitiation: item.requireAccountNumberOnInitiation,
      paymentMethodItemResponses: item.paymentMethodItemResponses
          .where((v) =>
              !PaymentConstants.isHiddenPaymentProvider(v.variantCode))
          .toList(),
    );
  }
}
