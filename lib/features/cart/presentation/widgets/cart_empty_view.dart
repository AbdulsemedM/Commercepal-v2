import 'package:flutter/material.dart';

import 'package:commercepal/core/widgets/app_empty_state.dart';
import 'package:commercepal/services/localization_service.dart';

/// Empty cart with routes back into shopping.
class CartEmptyView extends StatelessWidget {
  const CartEmptyView({
    super.key,
    required this.onStartShopping,
    this.onBrowseCategories,
  });

  final VoidCallback onStartShopping;
  final VoidCallback? onBrowseCategories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: AppEmptyState(
                icon: Icons.shopping_cart_outlined,
                title: context.tr('cart.emptyTitle'),
                subtitle: context.tr('cart.emptySubtitle'),
                primaryLabel: context.tr('cart.startShopping'),
                onPrimary: onStartShopping,
                secondaryLabel: onBrowseCategories != null
                    ? context.tr('home.categories.seeAll')
                    : null,
                onSecondary: onBrowseCategories,
              ),
            ),
          ),
        );
      },
    );
  }
}
