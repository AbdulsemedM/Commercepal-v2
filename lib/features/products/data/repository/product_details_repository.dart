import 'package:commercepal/core/storage/storage.dart';

import '../data_provider/product_details_data_provider.dart';
import '../models/product_details_response.dart';

class ProductDetailsRepository {
  ProductDetailsRepository({
    ProductDetailsDataProvider? dataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? ProductDetailsDataProvider(),
        _storage = storage ?? Storage();

  final ProductDetailsDataProvider _dataProvider;
  final Storage _storage;

  Future<ProductDetailsResponse> getProductDetails(
    String itemId, {
    String? country,
    String? currency,
  }) async {
    // Always use locally saved country and currency for X-Country and X-Currency headers
    final resolvedCountry = await _storage.getSelectedCountry();
    final resolvedCurrency = await _storage.getSelectedCurrency();

    return await _dataProvider.getProductDetails(
      itemId,
      country: resolvedCountry,
      currency: resolvedCurrency,
    );
  }
}
