import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/widgets/app_empty_state.dart';
import 'package:commercepal/core/widgets/shimmer_loading.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/navigation_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/products/bloc/product_search_bloc.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import 'package:commercepal/features/products/presentation/widgets/price_filter_chips.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/app_analytics.dart';

enum _ClientProductSort { relevance, priceAsc, priceDesc, nameAz }

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  static const double _loadMoreScrollThreshold = 200;

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  final Storage _storage = Storage();
  PriceRange _priceRange = const PriceRange();
  List<String> _recentSearches = <String>[];
  _ClientProductSort _clientSort = _ClientProductSort.relevance;

  Future<void> _loadRecentSearches() async {
    final List<String> next = await _storage.getRecentProductSearches();
    if (mounted) {
      setState(() => _recentSearches = next);
    }
  }

  List<Product> _sortInMemory(List<Product> products) {
    final List<Product> out = List<Product>.from(products);
    switch (_clientSort) {
      case _ClientProductSort.relevance:
        break;
      case _ClientProductSort.priceAsc:
        out.sort((Product a, Product b) => a.price.compareTo(b.price));
        break;
      case _ClientProductSort.priceDesc:
        out.sort((Product a, Product b) => b.price.compareTo(a.price));
        break;
      case _ClientProductSort.nameAz:
        out.sort(
          (Product a, Product b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
    }
    return out;
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    if (!mounted) return;

    // Spaces stay in the query (e.g. "men watch"); Dio encodes them for the API.
    final request = ProductSearchRequest(
      query: query,
      page: 0,
      size: 60,
    );

    context.read<ProductSearchBloc>().add(SearchProducts(request: request));

    await AppAnalytics.logSearch(searchTerm: query);
    await _storage.recordRecentProductSearch(query);
    if (mounted) {
      await _loadRecentSearches();
    }
  }

  void _onProductListScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels < position.maxScrollExtent - _loadMoreScrollThreshold) {
      return;
    }

    final bloc = context.read<ProductSearchBloc>();
    final ProductSearchState blocState = bloc.state;
    if (blocState is ProductSearchLoaded && blocState.hasMore) {
      bloc.add(LoadMoreProducts());
    }
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    NavigationService.instance.navigateToDashboardTab(context, tabIndex);
  }

  /// Opened with a prefilled query (e.g. subcategory tap).
  bool _hasInitialQuery() {
    return widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty;
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

  String _emptyResultsTitle(BuildContext context) {
    if (_hasInitialQuery()) {
      return LocalizationService.t(
        context,
        'productSearch.noResultsSubcategoryTitle',
      );
    }
    return LocalizationService.t(
      context,
      'productSearch.noResultsSearchTitle',
    );
  }

  String _emptyResultsSubtitle(BuildContext context) {
    if (_hasInitialQuery()) {
      return LocalizationService.t(
        context,
        'productSearch.noResultsSubcategorySubtitle',
      );
    }
    return LocalizationService.t(
      context,
      'productSearch.noResultsSearchSubtitle',
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _scrollController = ScrollController();
    _scrollController.addListener(_onProductListScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadRecentSearches();
      if (!mounted) return;
      if (_hasInitialQuery()) {
        await _performSearch();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onProductListScroll);
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

          final ColorScheme scheme = Theme.of(context).colorScheme;

          return BlocListener<ProductSearchBloc, ProductSearchState>(
            listenWhen:
                (ProductSearchState previous, ProductSearchState current) {
              if (current is! ProductSearchLoaded) {
                return false;
              }
              final ProductSearchLoaded curr = current;
              if (curr.noticeKey == null) {
                return false;
              }
              if (previous is ProductSearchLoaded &&
                  previous.noticeKey == curr.noticeKey) {
                return false;
              }
              return true;
            },
            listener: (BuildContext context, ProductSearchState state) {
              final ProductSearchLoaded s = state as ProductSearchLoaded;
              final String? key = s.noticeKey;
              if (key == null) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocalizationService.t(context, key)),
                ),
              );
              context.read<ProductSearchBloc>().add(ClearSearchNotice());
            },
            child: Scaffold(
              backgroundColor: scheme.surface,
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
                hasNotification: false,
              ),
              body: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: TextField(
                      controller: _searchController,
                      autofocus: !_hasInitialQuery(),
                      decoration: InputDecoration(
                        hintText: LocalizationService.t(
                          context,
                          'productSearch.fieldHint',
                        ),
                        hintStyle: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.search,
                            color: scheme.onSurfaceVariant,
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
                          borderSide:
                              BorderSide(color: scheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: scheme.outlineVariant),
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
                      onSubmitted: (_) {
                        _performSearch();
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  // Results
                  Expanded(
                    child: BlocBuilder<ProductSearchBloc, ProductSearchState>(
                      builder: (context, state) {
                        if (state is ProductSearchInitial) {
                          final String hint = LocalizationService.t(
                            context,
                            'productSearch.emptyHint',
                          );
                          if (!_hasInitialQuery() &&
                              _recentSearches.isNotEmpty) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(Spacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          LocalizationService.t(
                                            context,
                                            'productSearch.recentSearches',
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: scheme.onSurface,
                                              ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _storage
                                              .clearRecentProductSearches();
                                          if (mounted) {
                                            setState(() =>
                                                _recentSearches = <String>[]);
                                          }
                                        },
                                        child: Text(
                                          LocalizationService.t(
                                            context,
                                            'productSearch.clearRecent',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Spacing.sm),
                                  Wrap(
                                    spacing: Spacing.sm,
                                    runSpacing: Spacing.sm,
                                    children: _recentSearches.map((String q) {
                                      return InputChip(
                                        label: Text(
                                          q,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onPressed: () {
                                          _searchController.text = q;
                                          setState(() {});
                                          _performSearch();
                                        },
                                        onDeleted: () async {
                                          await _storage
                                              .removeRecentProductSearch(q);
                                          if (mounted) {
                                            await _loadRecentSearches();
                                          }
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: Spacing.xl),
                                  Center(
                                    child: Text(
                                      hint,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Center(
                            child: Text(
                              hint,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
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
                              childAspectRatio: 0.62,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return const ProductCardShimmer();
                            },
                          );
                        }

                        if (state is ProductSearchError) {
                          final ProductSearchError err = state;
                          final String displayMessage =
                              err.localizationKey != null
                                  ? LocalizationService.t(
                                      context,
                                      err.localizationKey!,
                                    )
                                  : err.message;
                          final bool isNetwork = err.localizationKey ==
                              'productSearch.errorNetwork';
                          final bool isSession =
                              err.localizationKey == 'checkout.sessionExpired';
                          return Center(
                            child: AppEmptyState(
                              icon: isNetwork
                                  ? Icons.wifi_off_outlined
                                  : isSession
                                      ? Icons.lock_clock_outlined
                                      : Icons.sentiment_dissatisfied_outlined,
                              title: displayMessage,
                              subtitle: isNetwork
                                  ? LocalizationService.t(
                                      context,
                                      'productSearch.errorNetworkHint',
                                    )
                                  : null,
                              primaryLabel: LocalizationService.t(
                                context,
                                'cart.retry',
                              ),
                              onPrimary: () {
                                if (_searchController.text.trim().isNotEmpty) {
                                  _performSearch();
                                }
                              },
                            ),
                          );
                        }

                        if (state is ProductSearchLoaded ||
                            state is ProductSearchLoadingMore) {
                          final List<Product> allProducts;
                          final int totalElements;
                          final bool loadingMoreFooter;

                          if (state is ProductSearchLoaded) {
                            allProducts = state.products;
                            totalElements = state.totalElements;
                            loadingMoreFooter = false;
                          } else if (state is ProductSearchLoadingMore) {
                            allProducts = state.products;
                            totalElements = state.totalElements;
                            loadingMoreFooter = true;
                          } else {
                            return const SizedBox.shrink();
                          }

                          if (allProducts.isEmpty) {
                            final bool canRetry =
                                _searchController.text.trim().isNotEmpty;
                            return Center(
                              child: AppEmptyState(
                                icon: Icons.search_off,
                                title: _emptyResultsTitle(context),
                                subtitle: _emptyResultsSubtitle(context),
                                primaryLabel: canRetry
                                    ? LocalizationService.t(
                                        context, 'cart.retry')
                                    : null,
                                onPrimary: canRetry ? _performSearch : null,
                              ),
                            );
                          }

                          final List<Product> sortedAll =
                              _sortInMemory(allProducts);
                          final filteredProducts = sortedAll
                              .where(
                                  (Product p) => _priceRange.contains(p.price))
                              .toList();
                          final hasActiveFilter = !_priceRange.isAny;
                          final maxPrice = allProducts
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
                                            ? 'Showing ${filteredProducts.length} of $totalElements'
                                            : '$totalElements results found',
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<_ClientProductSort>(
                                      initialValue: _clientSort,
                                      tooltip: LocalizationService.t(
                                        context,
                                        'productSearch.sortLabel',
                                      ),
                                      onSelected: (_ClientProductSort value) {
                                        setState(() => _clientSort = value);
                                      },
                                      itemBuilder: (BuildContext ctx) =>
                                          <PopupMenuEntry<_ClientProductSort>>[
                                        PopupMenuItem(
                                          value: _ClientProductSort.relevance,
                                          child: Text(
                                            LocalizationService.t(
                                              ctx,
                                              'productSearch.sortRelevance',
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: _ClientProductSort.priceAsc,
                                          child: Text(
                                            LocalizationService.t(
                                              ctx,
                                              'productSearch.sortPriceLow',
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: _ClientProductSort.priceDesc,
                                          child: Text(
                                            LocalizationService.t(
                                              ctx,
                                              'productSearch.sortPriceHigh',
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: _ClientProductSort.nameAz,
                                          child: Text(
                                            LocalizationService.t(
                                              ctx,
                                              'productSearch.sortName',
                                            ),
                                          ),
                                        ),
                                      ],
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Spacing.sm,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.sort,
                                              size: 20,
                                              color: scheme.onSurface,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              LocalizationService.t(
                                                context,
                                                'productSearch.sortLabel',
                                              ),
                                              style: TextStyle(
                                                color: scheme.onSurface,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
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
                                padding:
                                    const EdgeInsets.only(bottom: Spacing.sm),
                                child: PriceFilterChips(
                                  currentRange: _priceRange,
                                  currencySymbol: _getPriceFilterCurrencySymbol(
                                    allProducts,
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
                                        child: AppEmptyState(
                                          icon: Icons.filter_list_off,
                                          title: LocalizationService.t(
                                            context,
                                            'productSearch.noResultsPriceRange',
                                          ),
                                          primaryLabel: LocalizationService.t(
                                            context,
                                            'productSearch.clearPriceFilter',
                                          ),
                                          onPrimary: () {
                                            setState(() {
                                              _priceRange = const PriceRange();
                                            });
                                          },
                                        ),
                                      )
                                    : Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: RefreshIndicator(
                                              onRefresh: _performSearch,
                                              child: GridView.builder(
                                                controller: _scrollController,
                                                padding: const EdgeInsets.all(
                                                    Spacing.md),
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(),
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: Spacing.md,
                                                  mainAxisSpacing: Spacing.md,
                                                  childAspectRatio: 0.62,
                                                ),
                                                itemCount:
                                                    filteredProducts.length,
                                                itemBuilder: (context, index) {
                                                  final product =
                                                      filteredProducts[index];
                                                  return ProductCard(
                                                    key: ValueKey(
                                                      'product_${product.id}_$index',
                                                    ),
                                                    product: product,
                                                    productId: product.id,
                                                    imageUrl:
                                                        product.imageUrl ?? '',
                                                    description: product.name,
                                                    price:
                                                        MoneyFormatter.format(
                                                      product.price,
                                                      product.currency,
                                                    ),
                                                    originalPrice:
                                                        product.originalPrice !=
                                                                null
                                                            ? MoneyFormatter
                                                                .format(
                                                                product
                                                                    .originalPrice!,
                                                                product
                                                                    .currency,
                                                              )
                                                            : null,
                                                    rating: product.rating,
                                                    reviewCount:
                                                        product.reviewCount,
                                                    discountPercentage: product
                                                        .discountPercentage,
                                                    fillCell: true,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          if (loadingMoreFooter)
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: Spacing.md),
                                              child: Center(
                                                child: SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
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
        },
      ),
    );
  }
}
