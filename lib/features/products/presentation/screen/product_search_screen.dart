import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/widgets/shimmer_loading.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/navigation_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/products/bloc/product_search_bloc.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import 'package:commercepal/features/products/presentation/widgets/price_filter_chips.dart';
import 'package:commercepal/features/products/data/models/product.dart';

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
  PriceRange _priceRange = const PriceRange();

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
    );

    context.read<ProductSearchBloc>().add(SearchProducts(request: request));
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    NavigationService.instance.navigateToDashboardTab(context, tabIndex);
  }

  /// True when opened from subcategories (query + provider in URL).
  bool _isFromSubcategories() {
    return (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) &&
        (widget.providerId != null && widget.providerId!.isNotEmpty);
  }

  /// Uses backend product currency to get the symbol for the price filter.
  /// Falls back to app default currency if list is empty.
  String _getPriceFilterCurrencySymbol(List<Product> products) {
    final String code = products.isNotEmpty
        ? products.first.currency
        : CountryCurrencyConstants.defaultCurrencyCode;
    final String symbol = CountryCurrencyConstants.getCurrencySymbol(code);
    // Add space after multi-character symbols (e.g. "Br ", "KSh ") for readability
    return symbol.length > 1 ? '$symbol ' : symbol;
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
      child: BlocBuilder<CartBloc, CartState>(
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

          return Scaffold(
            appBar: AppBarWidget(
              cartCount: cartCount,
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
              onLogoTap: () => context.pop(),
              onCartTap: () => _navigateToTab(context, 2),
              onProfileTap: () => _navigateToTab(context, 3),
              hasNotification: true,
            ),
        body: Column(
          children: <Widget>[
            // Search bar (hidden when coming from subcategories with query + provider)
            if (!_isFromSubcategories())
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
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

                    final filteredProducts = state.products
                        .where((Product p) => _priceRange.contains(p.price))
                        .toList();
                    final hasActiveFilter = !_priceRange.isAny;
                    final maxPrice = state.products
                        .map((Product p) => p.price)
                        .fold(0.0, (double a, double b) => a > b ? a : b);

                    return Column(
                      children: <Widget>[
                        // Results count + price filter
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.md,
                            vertical: Spacing.xs,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  hasActiveFilter
                                      ? 'Showing ${filteredProducts.length} of ${state.totalElements}'
                                      : '${state.totalElements} results found',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (hasActiveFilter)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _priceRange = const PriceRange();
                                    });
                                  },
                                  child: const Text('Clear filter'),
                                ),
                            ],
                          ),
                        ),
                        // Price filter chips
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.sm),
                          child: PriceFilterChips(
                            currentRange: _priceRange,
                            currencySymbol: _getPriceFilterCurrencySymbol(
                              state.products,
                            ),
                            maxPriceInList: maxPrice,
                            onRangeChanged: (PriceRange range) {
                              setState(() => _priceRange = range);
                            },
                          ),
                        ),
                        // Product grid or empty filter state
                        Expanded(
                          child: filteredProducts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.filter_list_off,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: Spacing.md),
                                      Text(
                                        'No products in this price range',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: Spacing.sm),
                                      FilledButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _priceRange = const PriceRange();
                                          });
                                        },
                                        icon: const Icon(Icons.clear_all, size: 20),
                                        label: const Text('Clear price filter'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(Spacing.md),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: Spacing.md,
                                    mainAxisSpacing: Spacing.md,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = filteredProducts[index];
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
        );
        },
      ),
    );
  }
}
