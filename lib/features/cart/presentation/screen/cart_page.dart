import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/app/router/app_router.dart';
import '../../bloc/cart_bloc.dart';
import '../../data/models/cart.dart';
import '../widgets/cart_item_widget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void _navigateToTab(BuildContext context, int tabIndex) {
    final DashboardScreenState? dashboardState = context
        .findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.changeTab(tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the existing CartBloc from parent context (DashboardScreen)
    // instead of creating a new one
    return BlocListener<CartBloc, CartState>(
        listener: (context, state) {
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
          } else if (state is CartItemDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocalizationService.t(context, 'cart.itemRemoved')),
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
          backgroundColor: AppColors.lightGrey,
          appBar: AppBarWidget(
            cartCount: 0,
            userInitials: AuthService().userInitials ?? 'U',
            onSearchTap: () {
              // Navigate to search screen when search bar is tapped
              context.push(AppRoutes.productSearch);
            },
            onSearchSubmitted: (String query) {
              // Navigate to search screen with query
              context.push(
                '${AppRoutes.productSearch}?query=${Uri.encodeComponent(query)}',
              );
              return null;
            },
            onCartTap: () {
              // Navigate to cart tab
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
            builder: (context, state) {
              if (state is CartLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is CartError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: Spacing.md),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Spacing.lg),
                      FilledButton(
                        onPressed: () {
                          context.read<CartBloc>().add(CartLoadRequested());
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(LocalizationService.t(context, 'cart.retry')),
                      ),
                    ],
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

              // Initial state - show empty or loading
              return _buildEmptyCart(context);
            },
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            LocalizationService.t(context, 'cart.emptyTitle'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            LocalizationService.t(context, 'cart.emptySubtitle'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xl),
          FilledButton(
            onPressed: () {
              _navigateToTab(context, 0); // Navigate to home
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xl,
                vertical: Spacing.md,
              ),
            ),
            child: Text(LocalizationService.t(context, 'cart.startShopping')),
          ),
        ],
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
                // Cart items
                ...cart.items.map(
                  (item) => CartItemWidget(
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
        // Summary and actions
        _buildCartSummary(context, cart),
      ],
    );
  }

  Widget _buildCartSummary(BuildContext context, Cart cart) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Savings indicator
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
                  Icon(
                    Icons.savings_outlined,
                    size: 20,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      '${LocalizationService.t(context, 'cart.youreSaving')} ${cart.currency} ${cart.totalSavings.toStringAsFixed(2)}!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          // Price breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                LocalizationService.t(context, 'cart.subtotal'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '${cart.currency} ${cart.subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
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
                    ),
              ),
              Text(
                '${cart.currency} ${cart.estimatedTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Action buttons
          Row(
            children: <Widget>[
              // Clear cart button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.md,
                    ),
                  ),
                  child: Text(LocalizationService.t(context, 'cart.clearCart')),
                ),
              ),
              const SizedBox(width: Spacing.md),
              // Checkout button
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    context.push(
                      AppRoutes.checkoutSummary,
                      extra: cart,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.md,
                    ),
                  ),
                  child: Text(
                    LocalizationService.t(context, 'cart.checkout'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  void _showRemoveItemDialog(BuildContext context, cartItem) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(LocalizationService.t(context, 'cart.removeItem')),
        content: Text(
          '${LocalizationService.t(context, 'cart.removeItemConfirm')} "${cartItem.productName}"',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(LocalizationService.t(context, 'cart.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CartBloc>().add(
                    CartDeleteItemRequested(itemId: cartItem.id),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(LocalizationService.t(context, 'cart.remove')),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(LocalizationService.t(context, 'cart.clearCart')),
        content: Text(
          LocalizationService.t(context, 'cart.clearCartConfirm'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(LocalizationService.t(context, 'cart.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CartBloc>().add(CartClearRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(LocalizationService.t(context, 'cart.clear')),
          ),
        ],
      ),
    );
  }
}



