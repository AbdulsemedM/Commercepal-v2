import 'product.dart';
import 'product_search_response.dart';

class VisualSearchResult {
  const VisualSearchResult({
    this.message,
    required this.products,
    required this.currentPage,
    required this.hasNext,
  });

  final String? message;
  final List<Product> products;
  final int currentPage;
  final bool hasNext;

  factory VisualSearchResult.fromJson(
    Map<String, dynamic> json, {
    int fallbackPage = 0,
  }) {
    final String? message = json['message'] as String?;
    final searchResponse = ProductSearchResponse.fromJson(json);
    return VisualSearchResult(
      message: message,
      products: searchResponse.products,
      currentPage: searchResponse.currentPage,
      hasNext: searchResponse.hasNext,
    );
  }

  VisualSearchResult copyWithAppended(VisualSearchResult nextPage) {
    return VisualSearchResult(
      message: message ?? nextPage.message,
      products: <Product>[...products, ...nextPage.products],
      currentPage: nextPage.currentPage,
      hasNext: nextPage.hasNext,
    );
  }
}
