import 'package:flutter/material.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/home/presentation/widgets/home_product_rows.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/products/data/repository/product_search_repository.dart';

/// Horizontal row of products for a category, fed by the product search
/// API (same endpoint as search). Hides itself on failure or no results.
class CategoryTopPicks extends StatefulWidget {
  const CategoryTopPicks({
    super.key,
    required this.query,
    required this.title,
    this.repository,
  });

  final String query;
  final String title;
  final ProductSearchRepository? repository;

  @override
  State<CategoryTopPicks> createState() => _CategoryTopPicksState();
}

class _CategoryTopPicksState extends State<CategoryTopPicks> {
  static const int _fetchSize = 10;

  late final ProductSearchRepository _repository =
      widget.repository ?? ProductSearchRepository();

  List<Product> _products = const <Product>[];
  bool _loading = true;
  String? _loadedQuery;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CategoryTopPicks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _load();
  }

  Future<void> _load() async {
    final String query = widget.query.trim();
    if (query.isEmpty || query == _loadedQuery) return;
    _loadedQuery = query;
    setState(() => _loading = true);
    try {
      final response = await _repository.searchProducts(
        ProductSearchRequest(query: query, page: 0, size: _fetchSize),
      );
      if (!mounted || _loadedQuery != query) return;
      setState(() {
        _products = response.products
            .where((Product p) => p.id.isNotEmpty)
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted || _loadedQuery != query) return;
      setState(() {
        _products = const <Product>[];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: widget.title,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        ),
        if (_loading)
          SizedBox(
            height: homeProductRowHeight(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: kHomeProductRowVerticalInset,
              ),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
              itemBuilder: (_, __) => const SizedBox(
                width: kHomeProductCardWidth,
                child: ProductCardShimmer(),
              ),
            ),
          )
        else
          HomeProductRow(
            products: _products,
            horizontalPadding: Spacing.sm,
          ),
      ],
    );
  }
}
