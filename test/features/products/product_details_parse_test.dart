import 'package:flutter_test/flutter_test.dart';
import 'package:commercepal/core/utils/json_utils.dart';
import 'package:commercepal/features/products/data/models/product_details.dart';
import 'package:commercepal/features/products/data/models/product_details_response.dart';

void main() {
  group('JsonUtils', () {
    test('parses ints from double and string', () {
      expect(JsonUtils.asInt(1.0), 1);
      expect(JsonUtils.asInt('42'), 42);
      expect(JsonUtils.asIntOr(null, 7), 7);
    });

    test('coerces string lists from mixed values', () {
      expect(
        JsonUtils.asStringList(<dynamic>['a', 2, null, true]),
        <String>['a', '2', 'true'],
      );
      expect(JsonUtils.asStringList('single'), <String>['single']);
    });
  });

  group('ProductDetails.fromJson resilience', () {
    test('survives double stockLevel and string description', () {
      final ProductDetails details = ProductDetails.fromJson(<String, dynamic>{
        'id': 'p1',
        'title': 'Test',
        'stockLevel': 3.0,
        'minOrderQuantity': '2',
        'quantityStep': 1.0,
        'description': 'Color: Red',
        'meta': <String, dynamic>{'rating': 4.5, 'reviewCount': 10.0},
        'customerReviews': <dynamic>[
          <String, dynamic>{
            'content': 'Nice',
            'rating': 4.5,
            'images': <dynamic>[1, 'https://x'],
          },
        ],
        'recommendedProducts': <dynamic>[
          <String, dynamic>{'id': 'bad'}, // missing pricing/images/meta
          <String, dynamic>{
            'id': 'good',
            'title': 'Rec',
            'pricing': <String, dynamic>{'currentPrice': 10},
            'images': <String, dynamic>{'main': 'm', 'thumbnail': 't'},
            'meta': <String, dynamic>{'rating': 1, 'reviewCount': 0},
          },
        ],
        'variants': <dynamic>[
          <String, dynamic>{
            'configId': 'c1',
            'quantity': 5.0,
            'salesCount': '3',
          },
        ],
      });

      expect(details.stockLevel, 3);
      expect(details.minOrderQuantity, 2);
      expect(details.quantityStep, 1);
      expect(details.description, <String>['Color: Red']);
      expect(details.meta.reviewCount, 10);
      expect(details.customerReviews.single.rating, 4);
      expect(details.customerReviews.single.images, <String>['1', 'https://x']);
      expect(details.recommendedProducts.length, 1);
      expect(details.recommendedProducts.single.id, 'good');
      expect(details.variants.single.quantity, 5);
      expect(details.variants.single.salesCount, 3);
    });

    test('response with null data does not throw', () {
      final ProductDetailsResponse response =
          ProductDetailsResponse.fromJson(<String, dynamic>{
        'status': 200,
        'message': 'ok',
        'data': null,
      });
      expect(response.data, isNull);
      expect(response.status, 200);
    });
  });
}
