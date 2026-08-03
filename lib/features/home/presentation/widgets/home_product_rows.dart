import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:flutter/material.dart';

const int kHomeProductsPerRow = 5;
const double kHomeProductCardWidth = 150;
const double kHomeProductRowHeight = 330;
const double kHomeProductRowVerticalInset = 8;
const int kHomeDiscoverMaxProductsPerSection = kHomeProductsPerRow * 4;

List<List<Product>> chunkHomeProducts(
  List<Product> products, {
  required int maxProducts,
}) {
  final int capped = products.length.clamp(0, maxProducts);
  final List<Product> slice = products.take(capped).toList();
  final List<List<Product>> rows = <List<Product>>[];
  for (var i = 0; i < slice.length; i += kHomeProductsPerRow) {
    final int end = (i + kHomeProductsPerRow).clamp(0, slice.length);
    rows.add(slice.sublist(i, end));
  }
  return rows;
}

String formatHomeProductPrice(Product product) {
  final symbol = CountryCurrencyConstants.getCurrencySymbol(product.currency);
  final prefix = symbol.length > 1 ? '$symbol ' : symbol;
  return '$prefix${MoneyFormatter.formatAmount(product.price)}';
}

String? formatHomeProductOriginalPrice(Product product) {
  double? original = product.originalPrice;
  if (original == null &&
      product.discountPercentage != null &&
      product.discountPercentage! > 0 &&
      product.discountPercentage! < 100) {
    original = product.price / (1 - product.discountPercentage! / 100);
  }
  if (original == null || original <= product.price) return null;
  final symbol = CountryCurrencyConstants.getCurrencySymbol(product.currency);
  final prefix = symbol.length > 1 ? '$symbol ' : symbol;
  return '$prefix${MoneyFormatter.formatAmount(original)}';
}

class HomeProductRow extends StatelessWidget {
  const HomeProductRow({
    super.key,
    required this.products,
    this.imagePriorityBase = 0,
  });

  final List<Product> products;
  /// First product in this row gets [imagePriorityBase]; subsequent +1.
  final int imagePriorityBase;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kHomeProductRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: kHomeProductRowVerticalInset,
        ),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final Product p = products[index];
          return SizedBox(
            width: kHomeProductCardWidth,
            child: ProductCard(
              product: p,
              productId: p.id,
              imageUrl: p.imageUrl ?? '',
              description: p.name,
              price: formatHomeProductPrice(p),
              originalPrice: formatHomeProductOriginalPrice(p),
              rating: p.rating,
              reviewCount: p.reviewCount,
              discountPercentage: p.discountPercentage,
              currency: p.currency,
              imageLoadPriority: imagePriorityBase + index,
            ),
          );
        },
      ),
    );
  }
}
