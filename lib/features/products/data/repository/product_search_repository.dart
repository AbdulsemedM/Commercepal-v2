import '../data_provider/product_search_data_provider.dart';
import '../models/product_search_request.dart';
import '../models/product_search_response.dart';

class ProductSearchRepository {
  ProductSearchRepository({ProductSearchDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? ProductSearchDataProvider();

  final ProductSearchDataProvider _dataProvider;

  Future<ProductSearchResponse> searchProducts(
    ProductSearchRequest request,
  ) async {
    return await _dataProvider.searchProducts(request);
  }
}
