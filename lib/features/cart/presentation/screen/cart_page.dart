import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/widgets/app_dialog.dart';
import 'package:commercepal/core/widgets/app_empty_state.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/app/router/app_router.dart';
import '../../bloc/cart_bloc.dart';
import '../../data/models/cart.dart';
import '../../data/models/cart_item.dart';
import '../widgets/cart_item_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Duration _removeUndoWindow = Duration(seconds: 4);

  Timer? _pendingRemoveTimer;
  int? _pendingRemoveItemId;

  @override
  void dispose() {
    _pendingRemoveTimer?.cancel();
    super.dispose();
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    final DashboardScreenState? dashboardState = context
        .findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.changeTab(tabIndex);
    }
  }

  void _scheduleRemoveWithUndo(BuildContext context, CartItem item) {
    _pendingRemoveTimer?.cancel();
    _pendingRemoveItemId = item.id;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${LocalizationService.t(context, 'cart.removePending')} "${item.productName}"',
        ),
        action: SnackBarAction(
          label: LocalizationService.t(context, 'cart.undo'),
          onPressed: () {
            _pendingRemoveTimer?.cancel();
            _pendingRemoveTimer = null;
            _pendingRemoveItemId = null;
          },
        ),
        duration: _removeUndoWindow,
      ),
    );

    _pendingRemoveTimer = Timer(_removeUndoWindow, () {
      if (!mounted) return;
      if (_pendingRemoveItemId == item.id) {
        context.read<CartBloc>().add(CartDeleteItemRequested(itemId: item.id));
      }
      _pendingRemoveItemId = null;
      _pendingRemoveTimer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (BuildContext context, CartState state) {
        if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CartItemAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocalizationService.t(context, 'cart.itemAdded')),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CartItemUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocalizationService.t(context, 'cart.cartUpdated')),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CartCleared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocalizationService.t(context, 'cart.cartCleared')),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBarWidget(
          cartCount: 0,
          userInitials: AuthService().userInitials ?? 'U',
          onSearchTap: () {
            context.push(AppRoutes.productSearch);
          },
          onSearchSubmitted: (String query) {
            context.push(
              '${AppRoutes.productSearch}?query=${Uri.encodeComponent(query)}',
            );
            return null;
          },
          onCartTap: () {
            _navigateToTab(context, 2);
          },
          onProfileTap: () {
            _navigateToTab(context, 3);
          },
          hasNotification: false,
          searchPlaceholder: LocalizationService.t(
            context,
            'profile.searchPlaceholder',
          ),
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (BuildContext context, CartState state) {
            if (state is CartLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is CartError) {
              return Center(
                child: AppEmptyState(
                  icon: Icons.error_outline,
                  title: LocalizationService.t(context, 'cart.errorTitle'),
                  subtitle: state.message,
                  primaryLabel: LocalizationService.t(context, 'cart.retry'),
                  onPrimary: () {
                    context.read<CartBloc>().add(CartLoadRequested());
                  },
                  secondaryLabel:
                      LocalizationService.t(context, 'cart.clearCart'),
                  onSecondary: () {
                    _showClearCartDialog(context);
                  },
                ),
              );
            }

            if (state is CartLoaded ||
                state is CartItemAdded ||
                state is CartItemUpdated ||
                state is CartItemDeleted) {
              final Cart cart = state is CartLoaded
                  ? state.cart
                  : state is CartItemAdded
                      ? state.cart
                      : state is CartItemUpdated
                          ? state.cart
                          : (state as CartItemDeleted).cart;

              if (cart.items.isEmpty) {
                return _buildEmptyCart(context);
              }

              return _buildCartContent(context, cart);
            }

            return _buildEmptyCart(context);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.shopping_cart_outlined,
        title: LocalizationService.t(context, 'cart.emptyTitle'),
        subtitle: LocalizationService.t(context, 'cart.emptySubtitle'),
        primaryLabel: LocalizationService.t(context, 'cart.startShopping'),
        onPrimary: () => _navigateToTab(context, 0),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, Cart cart) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...cart.items.map(
                  (CartItem item) => CartItemWidget(
                    item: item,
                    onQuantityChanged: (int newQuantity) {
                      context.read<CartBloc>().add(
                            CartUpdateItemRequested(
                              itemId: item.id,
                              quantity: newQuantity,
                            ),
                          );
                    },
                    onRemove: () {
                      _showRemoveItemDialog(context, item);
                    },
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],
            ),
          ),
        ),
        _buildCartSummary(context, cart),
      ],
    );
  }

  Widget _buildCartSummary(BuildContext context, Cart cart) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (cart.totalSavings > 0)
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.savings_outlined,
                    size: 20,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      '${LocalizationService.t(context, 'cart.youreSaving')} ${MoneyFormatter.format(cart.totalSavings, cart.currency)}!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                LocalizationService.t(context, 'cart.subtotal'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                MoneyFormatter.format(cart.subtotal, cart.currency),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                LocalizationService.t(context, 'cart.estimatedTotal'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
              ),
              Text(
                MoneyFormatter.format(cart.estimatedTotal, cart.currency),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.md,
                    ),
                  ),
                  child: Text(LocalizationService.t(context, 'cart.clearCart')),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                flex: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppDecorations.primaryCtaGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.pink.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.push(
                          AppRoutes.checkoutSummary,
                          extra: cart,
                        );
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.md,
                        ),
                        child: Text(
                          LocalizationService.t(context, 'cart.checkout'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, CartItem cartItem) {
    AppDialog.show<void>(
      context,
      title: LocalizationService.t(context, 'cart.removeItem'),
      message:
          '${LocalizationService.t(context, 'cart.removeItemConfirm')} "${cartItem.productName}"',
      icon: const Icon(Icons.remove_shopping_cart_outlined),
      actions: <AppDialogAction>[
        AppDialogAction(label: LocalizationService.t(context, 'cart.cancel')),
        AppDialogAction(
          label: LocalizationService.t(context, 'cart.remove'),
          isDestructive: true,
          onPressed: () {
            _scheduleRemoveWithUndo(context, cartItem);
          },
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    AppDialog.show<void>(
      context,
      title: LocalizationService.t(context, 'cart.clearCart'),
      message: LocalizationService.t(context, 'cart.clearCartConfirm'),
      icon: const Icon(Icons.delete_sweep_outlined),
      actions: <AppDialogAction>[
        AppDialogAction(label: LocalizationService.t(context, 'cart.cancel')),
        AppDialogAction(
          label: LocalizationService.t(context, 'cart.clear'),
          isDestructive: true,
          onPressed: () {
            context.read<CartBloc>().add(CartClearRequested());
          },
        ),
      ],
    );
  }
}
