import 'package:flutter/material.dart';

import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/services/localization_service.dart';
import 'product_card.dart';

/// Client-only "continue browsing" strip from [Storage] local recent views.
class LocalRecentProductViewsStrip extends StatefulWidget {
  const LocalRecentProductViewsStrip({super.key});

  @override
  LocalRecentProductViewsStripState createState() =>
      LocalRecentProductViewsStripState();
}

class LocalRecentProductViewsStripState extends State<LocalRecentProductViewsStrip> {
  List<Map<String, dynamic>> _entries = <Map<String, dynamic>>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final list = await Storage().getLocalRecentProductViews();
    if (mounted) {
      setState(() {
        _entries = list;
        _loading = false;
      });
    }
  }

  String _formatPrice(Map<String, dynamic> e) {
    final price = (e['price'] as num?)?.toDouble() ?? 0;
    final code = e['currency'] as String? ??
        CountryCurrencyConstants.defaultCurrencyCode;
    final symbol = CountryCurrencyConstants.getCurrencySymbol(code);
    final prefix = symbol.length > 1 ? '$symbol ' : symbol;
    return '$prefix${MoneyFormatter.formatAmount(price)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Text(
            LocalizationService.t(context, 'home.localRecent.title'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
        ),
        const SizedBox(height: Spacing.md),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            itemCount: _entries.length,
            separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
            itemBuilder: (BuildContext context, int index) {
              final e = _entries[index];
              final id = e['productId'] as String? ?? '';
              final title = e['title'] as String? ?? '';
              final imageUrl = e['imageUrl'] as String? ?? '';
              return SizedBox(
                width: 160,
                child: ProductCard(
                  productId: id,
                  imageUrl: imageUrl,
                  description: title,
                  price: _formatPrice(e),
                  rating: (e['rating'] as num?)?.toDouble(),
                  reviewCount: (e['reviewCount'] as num?)?.toInt(),
                  showProgressBar: false,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.lg),
      ],
    );
  }
}
