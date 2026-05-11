import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/features/products/data/models/product_details.dart';
import 'package:commercepal/features/products/data/repository/product_details_repository.dart';
import 'package:commercepal/services/localization_service.dart';

enum _CompareRow { price, stock, weight, vendor }

/// Loads each product with the existing details API and shows a simple comparison table.
class ProductCompareScreen extends StatefulWidget {
  const ProductCompareScreen({super.key, required this.productIds});

  final List<String> productIds;

  @override
  State<ProductCompareScreen> createState() => _ProductCompareScreenState();
}

class _ProductCompareScreenState extends State<ProductCompareScreen> {
  final ProductDetailsRepository _repo = ProductDetailsRepository();
  final List<ProductDetails?> _details = <ProductDetails?>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _details.clear();
    });
    var ids = widget.productIds
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
    if (ids.isEmpty) {
      ids = await Storage().getProductCompareIds();
    }
    if (ids.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No products to compare';
        });
      }
      return;
    }
    try {
      for (final id in ids.take(4)) {
        final res = await _repo.getProductDetails(id);
        _details.add(res.data);
      }
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  String _cell(BuildContext context, _CompareRow row, ProductDetails d) {
    switch (row) {
      case _CompareRow.price:
        return MoneyFormatter.format(
          d.pricing.currentPrice,
          d.pricing.currency,
        );
      case _CompareRow.stock:
        return '${d.stockLevel}';
      case _CompareRow.weight:
        final w = d.physicalParameters.weight;
        return w > 0 ? '${w}g' : '—';
      case _CompareRow.vendor:
        return d.vendorName.isNotEmpty ? d.vendorName : d.provider;
    }
  }

  String _rowLabel(BuildContext context, _CompareRow row) {
    switch (row) {
      case _CompareRow.price:
        return LocalizationService.t(context, 'compare.rowPrice');
      case _CompareRow.stock:
        return LocalizationService.t(context, 'compare.rowStock');
      case _CompareRow.weight:
        return LocalizationService.t(context, 'compare.rowWeight');
      case _CompareRow.vendor:
        return LocalizationService.t(context, 'compare.rowVendor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.t(context, 'compare.title')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await Storage().setProductCompareIds(<String>[]);
              if (mounted) context.pop();
            },
            child: Text(LocalizationService.t(context, 'compare.clear')),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: Spacing.md),
                        FilledButton(
                          onPressed: _load,
                          child: Text(
                            LocalizationService.t(context, 'cart.retry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(Spacing.md),
                  child: _buildTable(context),
                ),
    );
  }

  Widget _buildTable(BuildContext context) {
    const rows = _CompareRow.values;
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.all(color: Colors.grey.shade300),
      children: <TableRow>[
        TableRow(
          children: <Widget>[
            const SizedBox(
              width: 120,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(''),
              ),
            ),
            ..._details.map((ProductDetails? d) {
              if (d == null) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('—'),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: 140,
                  child: Text(
                    d.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }),
          ],
        ),
        for (final row in rows)
          TableRow(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  _rowLabel(context, row),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              ..._details.map((ProductDetails? d) {
                if (d == null) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('—'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 140,
                    child: Text(
                      _cell(context, row, d),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ],
          ),
      ],
    );
  }
}
