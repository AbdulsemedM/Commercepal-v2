import 'package:flutter_test/flutter_test.dart';

import 'package:commercepal/features/products/data/models/visual_search_result.dart';

void main() {
  group('VisualSearchResult', () {
    test('parses image search response with message and items', () {
      final result = VisualSearchResult.fromJson(<String, dynamic>{
        'status': 200,
        'message': 'Results for: dress fashion',
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'cp-123',
              'title': 'Red Dress',
              'pricing': <String, dynamic>{
                'currency': 'ETB',
                'currentPrice': 2500.0,
                'formattedCurrentPrice': 'ETB 2,500.00',
              },
              'imageUrl': 'https://example.com/dress.jpg',
            },
          ],
          'pagination': <String, dynamic>{
            'page': 0,
            'size': 20,
            'hasNext': true,
            'hasPrevious': false,
          },
        },
      });

      expect(result.message, 'Results for: dress fashion');
      expect(result.products, hasLength(1));
      expect(result.products.first.id, 'cp-123');
      expect(result.products.first.name, 'Red Dress');
      expect(result.hasNext, isTrue);
      expect(result.currentPage, 0);
    });

    test('copyWithAppended merges product pages', () {
      final first = VisualSearchResult(
        message: 'Results for: shoes',
        products: const [],
        currentPage: 0,
        hasNext: true,
      );
      final second = VisualSearchResult(
        products: const [],
        currentPage: 1,
        hasNext: false,
      );

      final merged = first.copyWithAppended(second);
      expect(merged.message, 'Results for: shoes');
      expect(merged.currentPage, 1);
      expect(merged.hasNext, isFalse);
    });
  });
}
