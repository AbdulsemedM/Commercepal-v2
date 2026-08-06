import 'package:flutter/material.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/features/home/presentation/widgets/home_product_rows.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/products/data/repository/product_search_repository.dart';

/// Builds a search query from the first two words of a product title.
@visibleForTesting
String youMayAlsoLikeQuery(String title) {
  final List<String> words = title
      .trim()
      .split(RegExp(r'\s+'))
      .where((String w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  if (words.length == 1) return words.first;
  return '${words[0]} ${words[1]}';
}

/// Horizontal “You May Also Like” row fed by the product search API.
class YouMayAlsoLikeSection extends StatefulWidget {
  const YouMayAlsoLikeSection({
    super.key,
    required this.productId,
    required this.productTitle,
    this.repository,
  });

  final String productId;
  final String productTitle;
  final ProductSearchRepository? repository;

  @override
  State<YouMayAlsoLikeSection> createState() => _YouMayAlsoLikeSectionState();
}

class _YouMayAlsoLikeSectionState extends State<YouMayAlsoLikeSection> {
  static const int _fetchSize = 8;
  static const int _displayCount = 5;

  late final ProductSearchRepository _repository =
      widget.repository ?? ProductSearchRepository();

  List<Product> _products = const <Product>[];
  bool _loading = true;
  bool _failed = false;
  String? _lastFetchKey;

  @override
  void initState() {
    super.initState();
    _fetchIfNeeded();
  }

  @override
  void didUpdateWidget(covariant YouMayAlsoLikeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId ||
        oldWidget.productTitle != widget.productTitle) {
      _fetchIfNeeded(force: true);
    }
  }

  Future<void> _fetchIfNeeded({bool force = false}) async {
    final String query = youMayAlsoLikeQuery(widget.productTitle);
    final String fetchKey = '${widget.productId}|$query';
    if (!force && _lastFetchKey == fetchKey) return;
    _lastFetchKey = fetchKey;

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = false;
          _products = const <Product>[];
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _failed = false;
      });
    }

    try {
      final response = await _repository.searchProducts(
        ProductSearchRequest(
          query: query,
          page: 0,
          size: _fetchSize,
        ),
      );
      final List<Product> filtered = response.products
          .where((Product p) => p.id.isNotEmpty && p.id != widget.productId)
          .take(_displayCount)
          .toList();
      if (!mounted) return;
      setState(() {
        _products = filtered;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = const <Product>[];
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || (!_loading && _products.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Text(
              'You May Also Like',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          if (_loading)
            const SizedBox(
              height: kHomeProductRowHeight,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            SizedBox(
              height: kHomeProductRowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: kHomeProductRowVerticalInset,
                ),
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  final Product product = _products[index];
                  return SizedBox(
                    width: kHomeProductCardWidth,
                    child: ProductCard(
                      product: product,
                      productId: product.id,
                      imageUrl: product.imageUrl ?? '',
                      description: product.name,
                      price: formatHomeProductPrice(product),
                      originalPrice: formatHomeProductOriginalPrice(product),
                      rating: product.rating,
                      reviewCount: product.reviewCount,
                      discountPercentage: product.discountPercentage,
                      currency: product.currency,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
