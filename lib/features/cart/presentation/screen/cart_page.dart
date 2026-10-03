import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../bloc/cart_bloc.dart';
import '../../data/models/cart.dart';
import '../../data/models/cart_item.dart';
import '../widgets/cart_empty_view.dart';
import '../widgets/cart_item_widget.dart';

/// Cart tab: line items with optimistic remove + undo, unavailable-item
/// warning, and a sticky checkout summary.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Duration _removeUndoWindow = Duration(seconds: 4);

  final AuthService _authService = AuthService();
  late CartBloc _cartBloc;

  Timer? _pendingRemoveTimer;
  int? _pendingRemoveItemId;

  /// Line whose quantity update is in flight (drives the stepper spinner).
  int? _busyItemId;

  /// True while an action started on this page is in flight, so errors
  /// from adds elsewhere (e.g. product page) aren't reported twice.
  bool _actionInFlight = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartBloc = context.read<CartBloc>();
  }

  @override
  void dispose() {
    // Commit a pending removal rather than silently dropping it.
    if (_pendingRemoveTimer?.isActive == true && _pendingRemoveItemId != null) {
      _cartBloc.add(CartDeleteItemRequested(itemId: _pendingRemoveItemId!));
    }
    _pendingRemoveTimer?.cancel();
    super.dispose();
  }

  void _navigateToTab(int tabIndex) {
    context.findAncestorStateOfType<DashboardScreenState>()?.changeTab(tabIndex);
  }

  void _commitPendingRemove() {
    final int? id = _pendingRemoveItemId;
    _pendingRemoveTimer?.cancel();
    _pendingRemoveTimer = null;
    _pendingRemoveItemId = null;
    if (id != null) {
      _actionInFlight = true;
      _cartBloc.add(CartDeleteItemRequested(itemId: id));
    }
  }

  void _removeWithUndo(CartItem item) {
    // One pending removal at a time: commit the previous one now.
    if (_pendingRemoveItemId != null && _pendingRemoveItemId != item.id) {
      _commitPendingRemove();
    }
    setState(() => _pendingRemoveItemId = item.id);
    _pendingRemoveTimer?.cancel();
    _pendingRemoveTimer = Timer(_removeUndoWindow, () {
      if (!mounted) return;
      setState(_commitPendingRemove);
    });

    AppSnackbars.show(
      context,
      context.tr('cart.itemRemovedNamed', <String, Object?>{
        'name': item.productName,
      }),
      actionLabel: context.tr('cart.undo'),
      onAction: () {
        _pendingRemoveTimer?.cancel();
        _pendingRemoveTimer = null;
        if (mounted) setState(() => _pendingRemoveItemId = null);
      },
    );
  }

  void _updateQuantity(CartItem item, int quantity) {
    setState(() {
      _busyItemId = item.id;
      _actionInFlight = true;
    });
    _cartBloc.add(CartUpdateItemRequested(itemId: item.id, quantity: quantity));
  }

  void _checkout(Cart cart) {
    if (!_authService.isLoggedIn) {
      context.push(AppRoutes.login);
      return;
    }
    context.push(AppRoutes.checkoutSummary, extra: cart);
  }

  void _showClearCartDialog() {
    AppDialog.show<void>(
      context,
      title: context.tr('cart.clearCart'),
      message: context.tr('cart.clearCartConfirm'),
      icon: const Icon(Icons.delete_sweep_outlined),
      actions: <AppDialogAction>[
        AppDialogAction(label: context.tr('cart.cancel')),
        AppDialogAction(
          label: context.tr('cart.clear'),
          isDestructive: true,
          onPressed: () {
            _actionInFlight = true;
            _cartBloc.add(CartClearRequested());
          },
        ),
      ],
    );
  }

  void _onCartState(BuildContext context, CartState state) {
    if (state is CartLoading) return;
    final bool mine = _actionInFlight;
    setState(() {
      _busyItemId = null;
      _actionInFlight = false;
    });
    if (!mine) return;
    if (state is CartError) {
      AppSnackbars.error(context, state.message);
    } else if (state is CartCleared) {
      AppSnackbars.success(context, context.tr('cart.cartCleared'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: _onCartState,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (BuildContext context, CartState state) {
          // Keep showing the last cart while an update is in flight.
          final Cart? cart = state.cartOrNull ?? _cartBloc.lastKnownCart;
          final List<CartItem> items = cart == null
              ? const <CartItem>[]
              : cart.items
                  .where((CartItem i) => i.id != _pendingRemoveItemId)
                  .toList();
          final int count = items.fold(
            0,
            (int sum, CartItem i) => sum + i.quantity,
          );
          final bool loading = state is CartLoading || state is CartInitial;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                count > 0
                    ? context.tr('cart.titleCount', <String, Object?>{
                        'count': count,
                      })
                    : context.tr('nav.cart'),
              ),
              actions: <Widget>[
                if (items.isNotEmpty)
                  PopupMenuButton<String>(
                    tooltip: context.tr('product.moreActions'),
                    onSelected: (_) => _showClearCartDialog(),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'clear',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.delete_sweep_outlined,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(context.tr('cart.clearCart')),
                        ),
                      ),
                    ],
                  ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: (loading && cart != null)
                    ? const LinearProgressIndicator(minHeight: 2)
                    : const SizedBox(height: 2),
              ),
            ),
            body: _buildBody(context, state, cart, items, loading),
            bottomNavigationBar: (cart != null && items.isNotEmpty)
                ? _CheckoutBar(
                    cart: cart,
                    items: items,
                    itemCount: count,
                    onCheckout: () => _checkout(cart),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CartState state,
    Cart? cart,
    List<CartItem> items,
    bool loading,
  ) {
    if (cart == null) {
      if (state is CartError) {
        return AppEmptyState(
          isError: true,
          icon: Icons.error_outline_rounded,
          title: context.tr('cart.errorTitle'),
          subtitle: state.message,
          primaryLabel: context.tr('common.retry'),
          onPrimary: () => _cartBloc.add(CartLoadRequested()),
        );
      }
      if (loading) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          children: List<Widget>.generate(
            4,
            (_) => const ListTileShimmer(leadingSize: 88),
          ),
        );
      }
    }

    if (items.isEmpty) {
      return CartEmptyView(
        onStartShopping: () => _navigateToTab(0),
        onBrowseCategories: () => _navigateToTab(1),
      );
    }

    final List<CartItem> unavailable =
        items.where((CartItem i) => !i.isAvailable).toList();

    return RefreshIndicator(
      onRefresh: () async => _cartBloc.add(CartRefreshRequested()),
      child: ListView(
        padding: const EdgeInsets.all(Spacing.gutter),
        children: <Widget>[
          if (unavailable.isNotEmpty) ...<Widget>[
            _UnavailableBanner(
              count: unavailable.length,
              onRemoveAll: () {
                for (final CartItem i in unavailable) {
                  _actionInFlight = true;
                  _cartBloc.add(CartDeleteItemRequested(itemId: i.id));
                }
              },
            ),
            const SizedBox(height: Spacing.sm),
          ],
          for (final CartItem item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: CartItemWidget(
                key: ValueKey<int>(item.id),
                item: item,
                busy: _busyItemId == item.id ||
                    (_busyItemId != null && state is CartLoading),
                onTap: item.productId.isEmpty
                    ? null
                    : () => context.push(
                          Uri(
                            path: AppRoutes.productDetail,
                            queryParameters: <String, String>{
                              'id': item.productId,
                              'name': item.productName,
                              if (item.productImageUrl.isNotEmpty)
                                'image': item.productImageUrl,
                            },
                          ).toString(),
                        ),
                onQuantityChanged: (int q) => _updateQuantity(item, q),
                onRemove: () => _removeWithUndo(item),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnavailableBanner extends StatelessWidget {
  const _UnavailableBanner({required this.count, required this.onRemoveAll});

  final int count;
  final VoidCallback onRemoveAll;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.sm,
          Spacing.xs,
          Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                count == 1
                    ? context.tr('cart.unavailableBannerOne')
                    : context.tr('cart.unavailableBanner', <String, Object?>{
                        'count': count,
                      }),
                style: text.bodySmall?.copyWith(
                  color: scheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onRemoveAll,
              style: TextButton.styleFrom(
                foregroundColor: scheme.onErrorContainer,
              ),
              child: Text(context.tr('cart.remove')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.cart,
    required this.items,
    required this.itemCount,
    required this.onCheckout,
  });

  final Cart cart;
  final List<CartItem> items;
  final int itemCount;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CommerceColors c = context.commerce;
    final String symbol =
        CountryCurrencyConstants.getCurrencySymbol(cart.currency);
    final bool blocked = items.any((CartItem i) => !i.isAvailable);
    final bool canCheckout = !blocked && cart.estimatedTotal > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          Spacing.sm,
          Spacing.gutter,
          Spacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.tr('cart.estimatedTotal'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (cart.totalSavings > 0)
                        Text(
                          context.tr('cart.savingAmount', <String, Object?>{
                            'amount': MoneyFormatter.format(
                              cart.totalSavings,
                              symbol,
                            ),
                          }),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: c.success,
                          ),
                        ),
                    ],
                  ),
                ),
                PriceTag(
                  amount: cart.estimatedTotal,
                  currency: symbol,
                  size: PriceTagSize.medium,
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            AppButton.primary(
              label: context.tr('cart.proceedToCheckout', <String, Object?>{
                'count': itemCount,
              }),
              trailingIcon: Icons.lock_outline_rounded,
              onPressed: canCheckout ? onCheckout : null,
            ),
            if (blocked)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  context.tr('cart.checkoutBlockedUnavailable'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
