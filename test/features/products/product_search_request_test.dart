import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes accountType in query parameters', () {
    final request = ProductSearchRequest(
      query: 'bulk',
      page: 0,
      size: 8,
      accountType: 'BUSINESS',
    );

    expect(request.toQueryParameters(), {
      'page': 0,
      'size': 8,
      'query': 'bulk',
      'accountType': 'BUSINESS',
    });
  });
}
