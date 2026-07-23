import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/core/widgets/app_empty_state.dart';
import 'package:commercepal/core/widgets/shimmer_loading.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/theme/app_decorations.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/services/auth_service.dart';
import 'package:commercepal/services/navigation_service.dart';
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
  const ProductSearchScreen({
    super.key,
    this.initialQuery,
    this.initialAccountType,
  });

  final String? initialQuery;
  final String? initialAccountType;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  static const double _loadMoreScrollThreshold = 200;
  static const List<String> _suggestions = <String>[
    'Watches',
    'Perfume',
    'Laptop',
    'Shoes',
  ];

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
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
      accountType: widget.initialAccountType,
    );

    context.read<ProductSearchBloc>().add(SearchProducts(request: request));

    await AppAnalytics.logSearch(searchTerm: query);
    await _storage.recordRecentProductSearch(query);
    if (mounted) {
      await _loadRecentSearches();
    }
  }

  void _runSuggestion(String query) {
    _searchController.text = query;
    setState(() {});
    _performSearch();
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

  String _sortLabel(BuildContext context, _ClientProductSort sort) {
    switch (sort) {
      case _ClientProductSort.relevance:
        return LocalizationService.t(context, 'productSearch.sortRelevance');
      case _ClientProductSort.priceAsc:
        return LocalizationService.t(context, 'productSearch.sortPriceLow');
      case _ClientProductSort.priceDesc:
        return LocalizationService.t(context, 'productSearch.sortPriceHigh');
      case _ClientProductSort.nameAz:
        return LocalizationService.t(context, 'productSearch.sortName');
    }
  }

  Future<void> _openSortSheet() async {
    final _ClientProductSort? selected =
        await showModalBottomSheet<_ClientProductSort>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDecorations.radiusLg),
            ),
          ),
          padding: EdgeInsets.only(
            left: Spacing.lg,
            right: Spacing.lg,
            top: Spacing.md,
            bottom: MediaQuery.of(ctx).padding.bottom + Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                LocalizationService.t(ctx, 'productSearch.sortLabel'),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
              ),
              const SizedBox(height: Spacing.sm),
              for (final _ClientProductSort option in _ClientProductSort.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _sortLabel(ctx, option),
                    style: TextStyle(
                      fontWeight: option == _clientSort
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: AppColors.navy,
                    ),
                  ),
                  trailing: option == _clientSort
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(option),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _clientSort = selected);
    }
  }

  Widget _brandedEmptyWrap({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFFF4FA),
            AppColors.cream,
            Color(0xFFFFF8E8),
          ],
        ),
      ),
      child: Center(child: child),
    );
  }

  Widget _idleHero(BuildContext context) {
    final String hint = LocalizationService.t(
      context,
      'productSearch.emptyHint',
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFFFF4FA),
                  AppColors.cream,
                  Color(0xFFFFF8E8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
              boxShadow: AppDecorations.softCardShadow(),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.45),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Find something you love',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.65),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  alignment: WrapAlignment.center,
                  children: _suggestions.map((String q) {
                    return ActionChip(
                      label: Text(q),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      onPressed: () => _runSuggestion(q),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (_recentSearches.isNotEmpty) ...[
            const SizedBox(height: Spacing.lg),
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: AppDecorations.elevatedCard(
                background: Colors.white,
              ),
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
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _storage.clearRecentProductSearches();
                          if (mounted) {
                            setState(() => _recentSearches = <String>[]);
                          }
                        },
                        child: Text(
                          LocalizationService.t(
                            context,
                            'productSearch.clearRecent',
                          ),
                          style: const TextStyle(
                            color: AppColors.pink,
                            fontWeight: FontWeight.w600,
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
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: const Color(0xFFFFF4FA),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        deleteIconColor: AppColors.primary,
                        onPressed: () => _runSuggestion(q),
                        onDeleted: () async {
                          await _storage.removeRecentProductSearch(q);
                          if (mounted) {
                            await _loadRecentSearches();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppDecorations.softCardShadow(),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: !_hasInitialQuery(),
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cream,
            hintText: LocalizationService.t(
              context,
              'productSearch.fieldHint',
            ),
            hintStyle: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 15,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.md,
            ),
          ),
          onSubmitted: (_) => _performSearch(),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _searchFocusNode = FocusNode();
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
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: AppColors.cream,
              appBar: AppBarWidget(
                cartCount: cartCount,
                userInitials: AuthService().userInitials ?? 'U',
                onSearchTap: () => _searchFocusNode.requestFocus(),
                onSearchSubmitted: (String query) {
                  _searchController.text = query;
                  setState(() {});
                  _performSearch();
                  return null;
                },
                onLogoTap: () => context.pop(),
                onCartTap: () => _navigateToTab(context, 2),
                onProfileTap: () => _navigateToTab(context, 3),
                hasNotification: false,
              ),
              body: Column(
                children: <Widget>[
                  _buildSearchField(scheme),
                  Expanded(
                    child: BlocBuilder<ProductSearchBloc, ProductSearchState>(
                      builder: (context, state) {
                        if (state is ProductSearchInitial) {
                          return _idleHero(context);
                        }

                        if (state is ProductSearchLoading) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(Spacing.md),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: Spacing.md,
                              mainAxisSpacing: Spacing.md,
                              childAspectRatio: 0.52,
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
                          return _brandedEmptyWrap(
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
                            return _brandedEmptyWrap(
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.md,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Spacing.md,
                                    vertical: Spacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppDecorations.radiusMd,
                                    ),
                                    boxShadow: AppDecorations.softCardShadow(),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          hasActiveFilter
                                              ? 'Showing ${filteredProducts.length} of $totalElements'
                                              : '$totalElements results found',
                                          style: const TextStyle(
                                            color: AppColors.navy,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _openSortSheet,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: Spacing.xs,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const Icon(
                                                Icons.sort_rounded,
                                                size: 18,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                LocalizationService.t(
                                                  context,
                                                  'productSearch.sortLabel',
                                                ),
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
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
                                          child: Text(
                                            LocalizationService.t(
                                              context,
                                              'productSearch.clearPriceFilter',
                                            ),
                                            style: const TextStyle(
                                              color: AppColors.pink,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: Spacing.sm),
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
                              Expanded(
                                child: filteredProducts.isEmpty
                                    ? _brandedEmptyWrap(
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
                                              color: AppColors.primary,
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
                                                  childAspectRatio: 0.52,
                                                ),
                                                itemCount:
                                                    filteredProducts.length,
                                                itemBuilder: (context, index) {
                                                  final product =
                                                      filteredProducts[index];
                                                  return TweenAnimationBuilder<
                                                      double>(
                                                    tween: Tween<double>(
                                                      begin: 0,
                                                      end: 1,
                                                    ),
                                                    duration: Duration(
                                                      milliseconds:
                                                          220 + (index % 6) * 40,
                                                    ),
                                                    curve: Curves.easeOut,
                                                    builder: (context, value,
                                                        child) {
                                                      return Opacity(
                                                        opacity: value,
                                                        child: Transform
                                                            .translate(
                                                          offset: Offset(
                                                            0,
                                                            12 * (1 - value),
                                                          ),
                                                          child: child,
                                                        ),
                                                      );
                                                    },
                                                    child: ProductCard(
                                                      key: ValueKey(
                                                        'product_${product.id}_$index',
                                                      ),
                                                      product: product,
                                                      productId: product.id,
                                                      imageUrl:
                                                          product.imageUrl ?? '',
                                                      description: product.name,
                                                      price: MoneyFormatter
                                                          .format(
                                                        product.price,
                                                        product.currency,
                                                      ),
                                                      originalPrice: product
                                                                  .originalPrice !=
                                                              null
                                                          ? MoneyFormatter
                                                              .format(
                                                              product
                                                                  .originalPrice!,
                                                              product.currency,
                                                            )
                                                          : null,
                                                      rating: product.rating,
                                                      reviewCount:
                                                          product.reviewCount,
                                                      discountPercentage:
                                                          product
                                                              .discountPercentage,
                                                      fillCell: true,
                                                    ),
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
                                                    color: AppColors.primary,
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
