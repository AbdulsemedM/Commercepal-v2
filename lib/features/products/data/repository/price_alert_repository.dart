import 'package:commercepal/core/storage/storage.dart';

import '../data_provider/price_alert_data_provider.dart';

class PriceAlertRepository {
  PriceAlertRepository({
    PriceAlertDataProvider? dataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? PriceAlertDataProvider(),
        _storage = storage ?? Storage();

  final PriceAlertDataProvider _dataProvider;
  final Storage _storage;

  Future<double?> getLocalTargetPrice(String productId) {
    return _storage.getPriceAlertTarget(productId);
  }

  Future<void> setPriceAlert({
    required String productId,
    required double targetPrice,
  }) async {
    await _dataProvider.setPriceAlert(
      productId: productId,
      targetPrice: targetPrice,
    );
    await _storage.savePriceAlertTarget(productId, targetPrice);
  }

  Future<void> removePriceAlert({required String productId}) async {
    await _dataProvider.removePriceAlert(productId: productId);
    await _storage.removePriceAlertTarget(productId);
  }
}
