import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
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
    return BlocProvider(
      create: (context) => CartBloc()..add(CartLoadRequested()),
      child: BlocListener<CartBloc, CartState>(
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
              const SnackBar(
                content: Text('Item added to cart'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CartItemUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cart updated'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CartItemDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item removed from cart'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CartCleared) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cart cleared'),
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
            onSearchSubmitted: (String query) {
              return null;
            },
            onCartTap: () {
              // Already on cart page
            },
            onProfileTap: () {
              _navigateToTab(context, 3);
            },
            hasNotification: false,
            searchPlaceholder: LocalizationService.t(
              context,
              'nav.cart',
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
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is CartLoaded || state is CartItemAdded ||
                  state is CartItemUpdated || state is CartItemDeleted) {
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
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Add items to your cart to get started',
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
            child: const Text('Start Shopping'),
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
                      'You\'re saving ${cart.currency} ${cart.totalSavings.toStringAsFixed(2)}!',
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
                'Subtotal',
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
                'Estimated Total',
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
                  child: const Text('Clear Cart'),
                ),
              ),
              const SizedBox(width: Spacing.md),
              // Checkout button
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checkout functionality coming soon!'),
                        backgroundColor: Colors.blue,
                      ),
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
                  child: const Text(
                    'Checkout',
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
        title: const Text('Remove Item'),
        content: Text(
          'Are you sure you want to remove "${cartItem.productName}" from your cart?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CartBloc>().add(CartClearRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}



