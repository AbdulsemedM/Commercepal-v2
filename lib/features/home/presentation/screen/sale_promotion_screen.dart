import 'package:flutter/material.dart';

import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/features/home/presentation/widgets/promo_collection_scaffold.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/products/data/repository/product_search_repository.dart';

/// Banner 2 destination: sale promotion search (size 120).
class SalePromotionScreen extends StatefulWidget {
  const SalePromotionScreen({super.key});

  @override
  State<SalePromotionScreen> createState() => _SalePromotionScreenState();
}

class _SalePromotionScreenState extends State<SalePromotionScreen> {
  static const LinearGradient _heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.pink,
      AppColors.primary,
      Color(0xFFFF8FAB),
    ],
  );

  final ProductSearchRepository _repository = ProductSearchRepository();

  bool _loading = true;
  String? _error;
  List<Product> _products = <Product>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _repository.searchProducts(
        ProductSearchRequest(
          query: 'sale promotion',
          page: 0,
          size: 120,
        ),
      );
      if (!mounted) return;
      setState(() {
        _products = response.products;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load sale promotions. Pull to retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PromoCollectionScaffold(
      title: 'Sale & Promotions',
      subtitle: 'Curated picks for this season',
      heroGradient: _heroGradient,
      heroIcon: Icons.sell_rounded,
      badgeLabel: 'PROMO',
      isLoading: _loading,
      errorMessage: _error,
      products: _products,
      onRefresh: _load,
      emptyTitle: 'No promotions found',
      emptySubtitle: 'Sale promotions will appear here when available.',
    );
  }
}
