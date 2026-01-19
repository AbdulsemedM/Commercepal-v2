import '../data_provider/product_details_data_provider.dart';
import '../models/product_details_response.dart';

class ProductDetailsRepository {
  ProductDetailsRepository({ProductDetailsDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? ProductDetailsDataProvider();

  final ProductDetailsDataProvider _dataProvider;

  Future<ProductDetailsResponse> getProductDetails(
    String itemId, {
    String? country,
    String? currency,
  }) async {
    return await _dataProvider.getProductDetails(
      itemId,
      country: country,
      currency: currency,
    );
  }
}
