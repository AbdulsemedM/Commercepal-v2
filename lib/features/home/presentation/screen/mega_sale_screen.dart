import 'package:flutter/material.dart';

import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/features/home/data/home_discover_config.dart';
import 'package:commercepal/features/home/data/repository/home_discover_repository.dart';
import 'package:commercepal/features/home/presentation/widgets/promo_collection_scaffold.dart';
import 'package:commercepal/features/products/data/models/product.dart';

/// Banner 1 destination: home catalog products with 50%+ discount.
class MegaSaleScreen extends StatefulWidget {
  const MegaSaleScreen({super.key});

  @override
  State<MegaSaleScreen> createState() => _MegaSaleScreenState();
}

class _MegaSaleScreenState extends State<MegaSaleScreen> {
  static const LinearGradient _heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.primary,
      Color(0xFF7A034A),
      Color(0xFFB45309),
    ],
  );

  final HomeDiscoverRepository _repository = HomeDiscoverRepository();

  bool _loading = true;
  String? _error;
  List<Product> _products = <Product>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<Product> _filterDeepDiscounts(Map<String, List<Product>> sections) {
    final Set<String> seen = <String>{};
    final List<Product> out = <Product>[];
    for (final HomeDiscoverSectionConfig config in kHomeDiscoverSections) {
      final List<Product> list = sections[config.id] ?? <Product>[];
      for (final Product product in list) {
        final int? discount = product.discountPercentage;
        if (discount == null || discount < 50) continue;
        if (!seen.add(product.id)) continue;
        out.add(product);
      }
    }
    out.sort((Product a, Product b) {
      final int da = a.discountPercentage ?? 0;
      final int db = b.discountPercentage ?? 0;
      return db.compareTo(da);
    });
    return out;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cached = await _repository.getCachedPayload();
      final Map<String, List<Product>> cachedMap =
          cached?.data ?? <String, List<Product>>{};
      final List<Product> fromCache = _filterDeepDiscounts(cachedMap);
      if (fromCache.isNotEmpty && mounted) {
        setState(() {
          _products = fromCache;
          _loading = false;
        });
      }

      final Map<String, List<Product>> fresh = await _repository.fetchFresh();
      await _repository.saveCachedPayload(
        HomeDiscoverCachePayload(
          data: fresh,
          updatedAt: DateTime.now(),
        ),
      );
      final List<Product> filtered = _filterDeepDiscounts(fresh);

      if (!mounted) return;
      setState(() {
        _products = filtered;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      if (_products.isNotEmpty) {
        setState(() {
          _loading = false;
          _error = null;
        });
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Could not load mega sale deals. Pull to retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PromoCollectionScaffold(
      title: '50%+ Off',
      subtitle: 'Best deep discounts from Home',
      heroGradient: _heroGradient,
      heroIcon: Icons.local_fire_department_rounded,
      badgeLabel: 'MEGA SALE',
      isLoading: _loading,
      errorMessage: _error,
      products: _products,
      onRefresh: _load,
      emptyTitle: 'No deep discounts right now',
      emptySubtitle:
          'We could not find 50%+ deals in the home catalog. Check back soon.',
    );
  }
}
