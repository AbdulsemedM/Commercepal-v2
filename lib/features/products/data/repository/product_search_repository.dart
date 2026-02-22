import 'package:commercepal/core/storage/storage.dart';

import '../data_provider/product_search_data_provider.dart';
import '../models/product_search_request.dart';
import '../models/product_search_response.dart';

class ProductSearchRepository {
  ProductSearchRepository({
    ProductSearchDataProvider? dataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? ProductSearchDataProvider(),
        _storage = storage ?? Storage();

  final ProductSearchDataProvider _dataProvider;
  final Storage _storage;

  Future<ProductSearchResponse> searchProducts(
    ProductSearchRequest request,
  ) async {
    final country = await _storage.getSelectedCountry();
    final currency = await _storage.getSelectedCurrency();
    final resolvedRequest = request.copyWith(country: country, currency: currency);
    return await _dataProvider.searchProducts(resolvedRequest);
  }
}
