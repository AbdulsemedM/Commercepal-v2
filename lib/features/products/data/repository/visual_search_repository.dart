import 'package:commercepal/core/storage/storage.dart';

import '../data_provider/visual_search_data_provider.dart';
import '../models/visual_search_result.dart';

class VisualSearchRepository {
  VisualSearchRepository({
    VisualSearchDataProvider? dataProvider,
    Storage? storage,
  })  : _dataProvider = dataProvider ?? VisualSearchDataProvider(),
        _storage = storage ?? Storage();

  final VisualSearchDataProvider _dataProvider;
  final Storage _storage;

  Future<Map<String, String>> _headers() async {
    final String country = await _storage.getSelectedCountry();
    final String currency = await _storage.getSelectedCurrency();
    final Map<String, String> headers = <String, String>{};
    if (country.isNotEmpty) {
      headers['X-Country'] = country;
    }
    if (currency.isNotEmpty) {
      headers['X-Currency'] = currency;
    }
    return headers;
  }

  Future<VisualSearchResult> searchByImage({
    required String imageBase64,
    int page = 0,
    int size = 20,
  }) async {
    return _dataProvider.searchByImage(
      imageBase64: imageBase64,
      headers: await _headers(),
      page: page,
      size: size,
    );
  }

  Future<VisualSearchResult> searchByUrl({
    required String url,
    int page = 0,
    int size = 20,
  }) async {
    return _dataProvider.searchByUrl(
      url: url,
      headers: await _headers(),
      page: page,
      size: size,
    );
  }
}
