import '../data/data_provider/local_cart_data_provider.dart';
import '../data/models/cart.dart';
import '../data/models/cart_item.dart';
import 'cart_product_id.dart';

/// Result of consolidating duplicate cart lines that share product + variant.
class CartItemMergeResult {
  const CartItemMergeResult({
    required this.items,
    required this.extraLineIdsToDelete,
    required this.quantityUpdates,
  });

  final List<CartItem> items;

  /// Line ids that should be removed from the remote cart after merge.
  final List<int> extraLineIdsToDelete;

  /// Kept line id → summed quantity (only when quantity changed vs original).
  final Map<int, int> quantityUpdates;

  bool get hasDuplicates =>
      extraLineIdsToDelete.isNotEmpty || quantityUpdates.isNotEmpty;
}

String cartItemVariantKey(CartItem item) {
  final String productId = normalizeCartProductId(item.productId);
  final String? configId = normalizeCartConfigId(item.configId);
  return '$productId|${configId ?? ''}';
}

/// Groups lines by normalized `(productId, configId)`, keeps the smallest `id`,
/// and sums quantities. Subtotal uses kept line unit price × summed qty.
CartItemMergeResult mergeDuplicateCartItems(List<CartItem> items) {
  if (items.length <= 1) {
    return CartItemMergeResult(
      items: List<CartItem>.from(items),
      extraLineIdsToDelete: const <int>[],
      quantityUpdates: const <int, int>{},
    );
  }

  final Map<String, List<CartItem>> groups = <String, List<CartItem>>{};
  for (final CartItem item in items) {
    groups.putIfAbsent(cartItemVariantKey(item), () => <CartItem>[]).add(item);
  }

  final List<CartItem> merged = <CartItem>[];
  final List<int> extras = <int>[];
  final Map<int, int> quantityUpdates = <int, int>{};

  for (final List<CartItem> group in groups.values) {
    if (group.length == 1) {
      merged.add(group.first);
      continue;
    }

    group.sort((CartItem a, CartItem b) => a.id.compareTo(b.id));
    final CartItem kept = group.first;
    final int summedQty =
        group.fold<int>(0, (int sum, CartItem i) => sum + i.quantity);
    final List<int> groupExtras =
        group.skip(1).map((CartItem i) => i.id).toList();

    extras.addAll(groupExtras);
    if (summedQty != kept.quantity) {
      quantityUpdates[kept.id] = summedQty;
    }

    merged.add(
      CartItem(
        id: kept.id,
        productId: kept.productId,
        productName: kept.productName,
        productImageUrl: kept.productImageUrl,
        quantity: summedQty,
        unitPrice: kept.unitPrice,
        subtotal: kept.unitPrice * summedQty,
        currency: kept.currency,
        provider: kept.provider,
        stockStatus: kept.stockStatus,
        isAvailable: kept.isAvailable,
        priceWhenAdded: kept.priceWhenAdded,
        currentPrice: kept.currentPrice,
        priceDropped: kept.priceDropped,
        savingsAmount: kept.savingsAmount,
        configId: kept.configId,
      ),
    );
  }

  return CartItemMergeResult(
    items: merged,
    extraLineIdsToDelete: extras,
    quantityUpdates: quantityUpdates,
  );
}

/// Rebuilds cart totals from [items], preserving metadata from [source].
Cart cartWithMergedItems(Cart source, List<CartItem> items) {
  final int totalItems =
      items.fold<int>(0, (int sum, CartItem item) => sum + item.quantity);
  final double subtotal =
      items.fold<double>(0, (double sum, CartItem item) => sum + item.subtotal);
  return Cart(
    cartId: source.cartId,
    totalItems: totalItems,
    subtotal: subtotal,
    estimatedTotal: subtotal,
    currency: source.currency,
    lastActivityAt: source.lastActivityAt,
    items: items,
    priceDropItems: source.priceDropItems,
    unavailableItems: source.unavailableItems,
    totalSavings: source.totalSavings,
  );
}
