import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/widgets/app_network_image.dart';
import 'package:commercepal/services/localization_service.dart';

import '../../bloc/cart_bloc.dart';
import '../../data/models/cart.dart';
import '../../data/models/cart_item.dart';
import '../cart_checkout_launcher.dart';

/// Slides up after "Add to cart" and stays open: the item just added (with a
/// quantity stepper), the cart subtotal and savings, then Checkout or Keep
/// shopping. Shoppers no longer have to leave the product to see their cart.
Future<void> showAddedToCartSheet(
  BuildContext context, {
  required String productId,
}) {
  final CartBloc cartBloc = context.read<CartBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => BlocProvider<CartBloc>.value(
      value: cartBloc,
      child: _AddedToCartSheet(productId: productId),
    ),
  );
}

class _AddedToCartSheet extends StatelessWidget {
  const _AddedToCartSheet({required this.productId});

  final String productId;

  /// The line for the product just added (ids may carry a cp- prefix).
  CartItem? _lineFor(Cart cart) {
    String bare(String id) => id.replaceFirst(RegExp(r'^cp-'), '');
    final String wanted = bare(productId);
    for (final CartItem item in cart.items) {
      if (bare(item.productId) == wanted) return item;
    }
    return cart.items.isEmpty ? null : cart.items.last;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const Color green = Color(0xFF16A34A);
    return BlocBuilder<CartBloc, CartState>(
      builder: (BuildContext context, CartState state) {
        final CartBloc bloc = context.read<CartBloc>();
        final Cart? cart = state.cartOrNull ?? bloc.lastKnownCart;
        final CartItem? line = cart == null ? null : _lineFor(cart);
        final bool busy = state is CartLoading;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter, 0, Spacing.gutter, Spacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.check_circle_rounded, color: green, size: 26),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      context.tr('cart.sheet.added'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('common.close'),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              if (line != null)
                _LineCard(
                  item: line,
                  busy: busy,
                  onQuantity: (int q) => bloc.add(
                    CartUpdateItemRequested(itemId: line.id, quantity: q),
                  ),
                ),
              if (cart != null) ...<Widget>[
                const SizedBox(height: Spacing.md),
                const Divider(height: 1),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        context.tr('cart.sheet.subtotal', <String, Object?>{
                          'count': cart.totalItems,
                        }),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      MoneyFormatter.format(cart.subtotal, cart.currency),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (cart.totalSavings > 0) ...<Widget>[
                  const SizedBox(height: Spacing.xxs),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.local_offer_outlined, size: 16, color: green),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('cart.sheet.youSave', <String, Object?>{
                          'amount': MoneyFormatter.format(
                            cart.totalSavings,
                            cart.currency,
                          ),
                        }),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: Spacing.lg),
              AppButton.primary(
                key: const Key('added_to_cart_checkout'),
                label: context.tr('cart.checkout'),
                onPressed: cart == null || busy
                    ? null
                    : () async {
                        final NavigatorState nav = Navigator.of(context);
                        final BuildContext outer = nav.context;
                        nav.pop();
                        await startCartCheckout(outer, cart);
                      },
              ),
              const SizedBox(height: Spacing.xs),
              AppButton.secondary(
                label: context.tr('cart.sheet.keepShopping'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.item,
    required this.busy,
    required this.onQuantity,
  });

  final CartItem item;
  final bool busy;
  final ValueChanged<int> onQuantity;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: context.commerce.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppNetworkImage(
              url: item.productImageUrl,
              width: 64,
              height: 64,
              memCacheWidth: 192,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  MoneyFormatter.format(item.unitPrice, item.currency),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: context.commerce.price,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          _Stepper(
            quantity: item.quantity,
            busy: busy,
            onChanged: onQuantity,
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.busy,
    required this.onChanged,
  });

  final int quantity;
  final bool busy;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback? onTap) => SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 18,
            onPressed: busy ? null : onTap,
            icon: Icon(icon),
            style: IconButton.styleFrom(
              side: BorderSide(color: context.commerce.border),
              shape: const CircleBorder(),
            ),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        btn(Icons.remove_rounded, quantity > 1 ? () => onChanged(quantity - 1) : null),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        btn(Icons.add_rounded, () => onChanged(quantity + 1)),
      ],
    );
  }
}
