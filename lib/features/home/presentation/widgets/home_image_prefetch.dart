import 'package:commercepal/core/images/ordered_image_load_queue.dart';
import 'package:commercepal/features/home/presentation/widgets/home_product_rows.dart';
import 'package:commercepal/features/products/data/models/product.dart';

String? _lastPrefetchSignature;

/// Enqueues home product image URLs in visual order (section → product index).
/// Safe to call repeatedly; identical catalogs are ignored.
void prefetchHomeSectionImages({
  required List<List<Product>> sectionProducts,
  required int maxProductsPerSection,
}) {
  final List<String> urls = <String>[];
  final List<int> priorities = <int>[];
  final StringBuffer signature = StringBuffer();

  for (var sectionIndex = 0; sectionIndex < sectionProducts.length; sectionIndex++) {
    final List<Product> products = sectionProducts[sectionIndex];
    final int capped = products.length.clamp(0, maxProductsPerSection);
    signature.write('$sectionIndex:$capped|');
    for (var productIndex = 0; productIndex < capped; productIndex++) {
      final String? url = products[productIndex].imageUrl;
      if (url == null || url.trim().isEmpty) continue;
      final String trimmed = url.trim();
      urls.add(trimmed);
      priorities.add(sectionIndex * maxProductsPerSection + productIndex);
      signature.write(trimmed.hashCode);
      signature.write(',');
    }
  }

  final String sig = signature.toString();
  if (sig.isEmpty || sig == _lastPrefetchSignature || urls.isEmpty) return;
  _lastPrefetchSignature = sig;

  OrderedImageLoadQueue.instance.prefetchOrdered(
    urls,
    priorityForIndex: (int index) => priorities[index],
  );
}

/// Convenience for discover/wholesale maps keyed by section id in config order.
void prefetchHomeCatalogImages({
  required List<String> sectionIdsInOrder,
  required Map<String, List<Product>> sections,
  int maxProductsPerSection = kHomeDiscoverMaxProductsPerSection,
}) {
  prefetchHomeSectionImages(
    sectionProducts: sectionIdsInOrder
        .map((String id) => sections[id] ?? const <Product>[])
        .toList(),
    maxProductsPerSection: maxProductsPerSection,
  );
}
