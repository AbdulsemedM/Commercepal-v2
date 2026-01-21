import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/widgets/shimmer_loading.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/features/dashboard/dashboard_screen.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/features/products/bloc/product_search_bloc.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key, this.initialQuery, this.providerId});

  final String? initialQuery;
  final String? providerId;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  void _performSearch() {
    final query = _searchController.text.trim();
    
    // Allow search if either query or providerId is provided
    if (query.isEmpty && widget.providerId == null) {
      return;
    }

    if (!mounted) return;

    final request = ProductSearchRequest(
      query: query.isNotEmpty ? query : null,
      provider: widget.providerId,
      page: 0,
      size: 36,
      country: 'ET',
      currency: 'USD',
    );

    context.read<ProductSearchBloc>().add(SearchProducts(request: request));
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    final DashboardScreenState? dashboardState = context
        .findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.changeTab(tabIndex);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _scrollController = ScrollController();

    // Perform initial search if query or providerId is provided
    if ((widget.initialQuery != null && widget.initialQuery!.isNotEmpty) ||
        (widget.providerId != null && widget.providerId!.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get or create CartBloc
    CartBloc? cartBloc;
    try {
      cartBloc = context.read<CartBloc>();
    } catch (e) {
      cartBloc = CartBloc();
    }

    return BlocProvider.value(
      value: cartBloc,
      child: Scaffold(
        appBar: _CartAppBar(
          cartBloc: cartBloc,
          onLogo: () => context.pop(),
          onCart: () => _navigateToTab(context, 2),
          onProfile: () => _navigateToTab(context, 3),
        ),
        body: Column(
          children: <Widget>[
            // Search bar
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.sm,
                  ),
                ),
                onSubmitted: (_) => _performSearch(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            // Results
            Expanded(
              child: BlocBuilder<ProductSearchBloc, ProductSearchState>(
                builder: (context, state) {
                  if (state is ProductSearchInitial) {
                    return Center(
                      child: Text(
                        widget.providerId != null
                            ? 'Loading products...'
                            : 'Enter a search query to find products',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  if (state is ProductSearchLoading) {
                    // Show shimmer loading effect
                    return GridView.builder(
                      padding: const EdgeInsets.all(Spacing.md),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: Spacing.md,
                            mainAxisSpacing: Spacing.md,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return const ProductCardShimmer();
                      },
                    );
                  }

                  if (state is ProductSearchError) {
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
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.md),
                          ElevatedButton(
                            onPressed: () {
                              if (_searchController.text.isNotEmpty ||
                                  widget.providerId != null) {
                                _performSearch();
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProductSearchLoaded) {
                    if (state.products.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: Spacing.md),
                            Text(
                              'No products found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: <Widget>[
                        // Results count
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.md,
                            vertical: Spacing.sm,
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                '${state.totalElements} results found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Product grid
                        Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(Spacing.md),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: Spacing.md,
                                  mainAxisSpacing: Spacing.md,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: state.products.length,
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              return ProductCard(
                                key: ValueKey('product_${product.id}_$index'),
                                productId: product.id,
                                imageUrl: product.imageUrl ?? '',
                                description: product.name,
                                price:
                                    '${product.currency} ${product.price.toStringAsFixed(2)}',
                                originalPrice: product.originalPrice != null
                                    ? '${product.currency} ${product.originalPrice!.toStringAsFixed(2)}'
                                    : null,
                                rating: product.rating,
                                reviewCount: product.reviewCount,
                                discountPercentage: product.discountPercentage,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CartAppBar({
    required this.cartBloc,
    required this.onLogo,
    required this.onCart,
    required this.onProfile,
  });

  final CartBloc? cartBloc;
  final VoidCallback onLogo;
  final VoidCallback onCart;
  final VoidCallback onProfile;

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight + 20);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      bloc: cartBloc,
      buildWhen: (previous, current) {
        int prevCount = 0;
        int currCount = 0;
        if (previous is CartLoaded ||
            previous is CartItemAdded ||
            previous is CartItemUpdated ||
            previous is CartItemDeleted) {
          final prevCart = previous is CartLoaded
              ? previous.cart
              : previous is CartItemAdded
              ? previous.cart
              : previous is CartItemUpdated
              ? previous.cart
              : (previous as CartItemDeleted).cart;
          prevCount = prevCart.totalItems;
        }
        if (current is CartLoaded ||
            current is CartItemAdded ||
            current is CartItemUpdated ||
            current is CartItemDeleted) {
          final currCart = current is CartLoaded
              ? current.cart
              : current is CartItemAdded
              ? current.cart
              : current is CartItemUpdated
              ? current.cart
              : (current as CartItemDeleted).cart;
          currCount = currCart.totalItems;
        }
        return prevCount != currCount;
      },
      builder: (context, cartState) {
        int cartCount = 0;
        if (cartState is CartLoaded ||
            cartState is CartItemAdded ||
            cartState is CartItemUpdated ||
            cartState is CartItemDeleted) {
          final cart = cartState is CartLoaded
              ? cartState.cart
              : cartState is CartItemAdded
              ? cartState.cart
              : cartState is CartItemUpdated
              ? cartState.cart
              : (cartState as CartItemDeleted).cart;
          cartCount = cart.totalItems;
        }

        return AppBarWidget(
          cartCount: cartCount,
          userInitials: AuthService().userInitials ?? 'U',
          onSearchSubmitted: (String query) {
            // This won't be used since we're already on search screen
            return null;
          },
          onLogoTap: onLogo,
          onCartTap: onCart,
          onProfileTap: onProfile,
          hasNotification: true,
        );
      },
    );
  }
}
