import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/products/data/models/product.dart';

import '../data_provider/recently_viewed_data_provider.dart';

class RecentlyViewedRepository {
  RecentlyViewedRepository({
    RecentlyViewedDataProvider? dataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? RecentlyViewedDataProvider(),
        _storage = storage ?? Storage();

  final RecentlyViewedDataProvider _dataProvider;
  final Storage _storage;

  Future<List<Product>> getRecentlyViewed() async {
    final country = await _storage.getSelectedCountry();
    final currency = await _storage.getSelectedCurrency();
    return _dataProvider.getRecentlyViewed(
      country: country,
      currency: currency,
    );
  }
}
