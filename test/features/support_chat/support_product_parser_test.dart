import 'package:flutter_test/flutter_test.dart';

import 'package:commercepal/features/support_chat/utils/support_product_parser.dart';

void main() {
  group('parseSupportMessageProducts', () {
    test('extracts products from PRODUCTS block and preserves text', () {
      const message =
          'Here are some options:\n'
          '[PRODUCTS]'
          '[{"id":"cp-1","title":"Red Dress","image":"https://x/img.jpg","price":"ETB 100"}]'
          '[/PRODUCTS]\n'
          'Tap a card to view details.';

      final parsed = parseSupportMessageProducts(message);

      expect(parsed.textSegments, hasLength(2));
      expect(parsed.textSegments.first, contains('Here are some options'));
      expect(parsed.textSegments.last, contains('Tap a card'));
      expect(parsed.products, hasLength(1));
      expect(parsed.products.first.id, 'cp-1');
      expect(parsed.products.first.title, 'Red Dress');
      expect(parsed.products.first.image, 'https://x/img.jpg');
      expect(parsed.products.first.price, 'ETB 100');
    });

    test('returns plain text when no PRODUCTS block exists', () {
      const message = 'Hello, how can I help?';
      final parsed = parseSupportMessageProducts(message);

      expect(parsed.products, isEmpty);
      expect(parsed.textSegments, <String>['Hello, how can I help?']);
    });

    test('parses single object payload inside PRODUCTS block', () {
      const message =
          '[PRODUCTS]{"id":"cp-9","title":"Watch","images":["https://x/w.jpg"],"pricing":{"formattedCurrentPrice":"ETB 50"}}[/PRODUCTS]';

      final parsed = parseSupportMessageProducts(message);
      expect(parsed.products, hasLength(1));
      expect(parsed.products.first.id, 'cp-9');
      expect(parsed.products.first.price, 'ETB 50');
      expect(parsed.products.first.image, 'https://x/w.jpg');
    });
  });
}
