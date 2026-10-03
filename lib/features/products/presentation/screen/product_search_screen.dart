import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/widgets/app_bar.dart';
import 'package:commercepal/features/cart/bloc/cart_bloc.dart';
import 'package:commercepal/features/home/presentation/widgets/product_card.dart';
import 'package:commercepal/features/products/bloc/product_search_bloc.dart';
import 'package:commercepal/features/products/data/models/product.dart';
import 'package:commercepal/features/products/data/models/product_search_request.dart';
import 'package:commercepal/features/products/presentation/widgets/price_filter_chips.dart';
import 'package:commercepal/services/app_analytics.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/services/navigation_service.dart';

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
  static const double _loadMoreScrollThreshold = 400;

  /// (locale key, English query sent to the catalogue API).
  static const List<(String, String)> _suggestions = <(String, String)>[
    ('productSearch.suggestion.watches', 'Watches'),
    ('productSearch.suggestion.perfume', 'Perfume'),
    ('productSearch.suggestion.laptop', 'Laptop'),
    ('productSearch.suggestion.shoes', 'Shoes'),
    ('productSearch.suggestion.phones', 'Smart phones'),
    ('productSearch.suggestion.headphones', 'Headphones'),
  ];

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;
  final Storage _storage = Storage();
  PriceRange _priceRange = const PriceRange();
  List<String> _recentSearches = <String>[];
  _ClientProductSort _clientSort = _ClientProductSort.relevance;

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
    final String query = _searchController.text.trim();
    if (query.isEmpty || !mounted) return;

    _searchFocusNode.unfocus();
    // A new query starts from a clean filter state.
    setState(() => _priceRange = const PriceRange());

    // Spaces stay in the query (e.g. "men watch"); Dio encodes them for the API.
    final ProductSearchRequest request = ProductSearchRequest(
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
    _performSearch();
  }

  void _onProductListScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final ScrollPosition position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels < position.maxScrollExtent - _loadMoreScrollThreshold) {
      return;
    }
    final ProductSearchBloc bloc = context.read<ProductSearchBloc>();
    final ProductSearchState blocState = bloc.state;
    if (blocState is ProductSearchLoaded && blocState.hasMore) {
      bloc.add(LoadMoreProducts());
    }
  }

  /// Opened with a prefilled query (e.g. subcategory tap).
  bool _hasInitialQuery() {
    return widget.initialQuery != null &&
        widget.initialQuery!.trim().isNotEmpty;
  }

  /// Uses backend product currency to get the symbol for the price filter.
  String _currencySymbol(List<Product> products) {
    final String code = products.isNotEmpty
        ? products.first.currency
        : CountryCurrencyConstants.defaultCurrencyCode;
    final String symbol = CountryCurrencyConstants.getCurrencySymbol(code);
    // Space after multi-character symbols (e.g. "Br ", "KSh ").
    return symbol.length > 1 ? '$symbol ' : symbol;
  }

  String _sortLabel(BuildContext context, _ClientProductSort sort) {
    return switch (sort) {
      _ClientProductSort.relevance => context.tr('productSearch.sortRelevance'),
      _ClientProductSort.priceAsc => context.tr('productSearch.sortPriceLow'),
      _ClientProductSort.priceDesc => context.tr('productSearch.sortPriceHigh'),
      _ClientProductSort.nameAz => context.tr('productSearch.sortName'),
    };
  }

  Future<void> _openSortSheet() async {
    final _ClientProductSort? selected =
        await showModalBottomSheet<_ClientProductSort>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  0,
                  Spacing.lg,
                  Spacing.xs,
                ),
                child: Text(
                  ctx.tr('productSearch.sortLabel'),
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
              ),
              RadioGroup<_ClientProductSort>(
                groupValue: _clientSort,
                onChanged: (_ClientProductSort? v) => Navigator.of(ctx).pop(v),
                child: Column(
                  children: <Widget>[
                    for (final _ClientProductSort option
                        in _ClientProductSort.values)
                      RadioListTile<_ClientProductSort>(
                        value: option,
                        title: Text(_sortLabel(ctx, option)),
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.sm),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _clientSort = selected);
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    }
  }

  // ---------------------------------------------------------------------------
  // Idle: recent + popular searches
  // ---------------------------------------------------------------------------

  Widget _idleView(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: <Widget>[
        if (_recentSearches.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.sm),
          SectionHeader(
            title: context.tr('productSearch.recentSearches'),
            actionLabel: context.tr('productSearch.clearRecent'),
            onAction: () async {
              await _storage.clearRecentProductSearches();
              if (mounted) setState(() => _recentSearches = <String>[]);
            },
          ),
          for (final String q in _recentSearches.take(8))
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(q, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => _runSuggestion(q),
              trailing: IconButton(
                tooltip: context.tr('common.remove'),
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () async {
                  await _storage.removeRecentProductSearch(q);
                  if (mounted) await _loadRecentSearches();
                },
              ),
            ),
          const Divider(height: Spacing.xl),
        ],
        const SizedBox(height: Spacing.sm),
        SectionHeader(title: context.tr('productSearch.popular')),
        const SizedBox(height: Spacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
          child: Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: <Widget>[
              for (final (String key, String query) in _suggestions)
                ActionChip(
                  avatar: Icon(
                    Icons.trending_up_rounded,
                    size: 18,
                    color: scheme.primary,
                  ),
                  label: Text(context.tr(key)),
                  onPressed: () => _runSuggestion(query),
                ),
            ],
          ),
        ),
        if (_recentSearches.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              Spacing.xl,
              Spacing.gutter,
              0,
            ),
            child: Text(
              context.tr('productSearch.emptyHint'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Results
  // ---------------------------------------------------------------------------

  SliverGridDelegate get _gridDelegate =>
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Spacing.sm,
        mainAxisSpacing: Spacing.sm,
        childAspectRatio: kProductGridAspectRatio,
      );

  Widget _loadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(Spacing.gutter),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: _gridDelegate,
      itemCount: 6,
      itemBuilder: (_, __) => const ProductCardShimmer(),
    );
  }

  Widget _results(
    BuildContext context, {
    required List<Product> allProducts,
    required int totalElements,
    required bool loadingMore,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final List<Product> filtered = _sortInMemory(allProducts)
        .where((Product p) => _priceRange.contains(p.price))
        .toList();
    final bool hasActiveFilter = !_priceRange.isAny;
    final bool sorted = _clientSort != _ClientProductSort.relevance;

    final Widget sortChip = FilterChip(
      avatar: Icon(
        Icons.swap_vert_rounded,
        size: 18,
        color: sorted ? scheme.onPrimaryContainer : scheme.onSurface,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            sorted
                ? _sortLabel(context, _clientSort)
                : context.tr('productSearch.sortLabel'),
          ),
          const Icon(Icons.arrow_drop_down_rounded, size: 20),
        ],
      ),
      selected: sorted,
      onSelected: (_) => _openSortSheet(),
    );

    return RefreshIndicator(
      onRefresh: _performSearch,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: PriceFilterChips(
                leading: <Widget>[sortChip],
                currentRange: _priceRange,
                currencySymbol: _currencySymbol(allProducts),
                prices: allProducts.map((Product p) => p.price).toList(),
                onRangeChanged: (PriceRange range) {
                  setState(() => _priceRange = range);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter,
                Spacing.sm,
                Spacing.gutter,
                Spacing.xxs,
              ),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  hasActiveFilter
                      ? context.tr('productSearch.showingOf', <String, Object?>{
                          'shown': filtered.length,
                          'total': MoneyFormatter.formatWhole(totalElements),
                        })
                      : context.tr('productSearch.resultsCount', <String, Object?>{
                          'count': MoneyFormatter.formatWhole(totalElements),
                        }),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: Icons.filter_list_off_rounded,
                title: context.tr('productSearch.noResultsPriceRange'),
                primaryLabel: context.tr('productSearch.clearPriceFilter'),
                onPrimary: () =>
                    setState(() => _priceRange = const PriceRange()),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter,
                Spacing.xs,
                Spacing.gutter,
                Spacing.gutter,
              ),
              sliver: SliverGrid.builder(
                gridDelegate: _gridDelegate,
                itemCount: filtered.length,
                itemBuilder: (BuildContext context, int index) {
                  final Product product = filtered[index];
                  return ProductCard(
                    key: ValueKey<String>('product_${product.id}_$index'),
                    product: product,
                    productId: product.id,
                    imageUrl: product.imageUrl ?? '',
                    description: product.name,
                    price: MoneyFormatter.format(
                      product.price,
                      product.currency,
                    ),
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                    discountPercentage: product.discountPercentage,
                    fillCell: true,
                    imageLoadPriority: index,
                  );
                },
              ),
            ),
          if (loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: Spacing.xl),
                child: Center(
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ProductSearchState state) {
    if (state is ProductSearchInitial) {
      return _idleView(context);
    }
    if (state is ProductSearchLoading) {
      return _loadingGrid();
    }
    if (state is ProductSearchError) {
      final String message = state.localizationKey != null
          ? context.tr(state.localizationKey!)
          : state.message;
      final bool isNetwork =
          state.localizationKey == 'productSearch.errorNetwork';
      final bool isSession =
          state.localizationKey == 'checkout.sessionExpired';
      return AppEmptyState(
        isError: true,
        icon: isNetwork
            ? Icons.wifi_off_rounded
            : isSession
                ? Icons.lock_clock_outlined
                : Icons.error_outline_rounded,
        title: message,
        subtitle:
            isNetwork ? context.tr('productSearch.errorNetworkHint') : null,
        primaryLabel: context.tr('common.retry'),
        onPrimary: _searchController.text.trim().isNotEmpty
            ? _performSearch
            : null,
      );
    }

    final (List<Product>, int, bool)? data = switch (state) {
      ProductSearchLoaded(:final products, :final totalElements) => (
          products,
          totalElements,
          false,
        ),
      ProductSearchLoadingMore(:final products, :final totalElements) => (
          products,
          totalElements,
          true,
        ),
      _ => null,
    };
    if (data == null) return const SizedBox.shrink();

    if (data.$1.isEmpty) {
      final bool sub = _hasInitialQuery();
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: context.tr(
          sub
              ? 'productSearch.noResultsSubcategoryTitle'
              : 'productSearch.noResultsSearchTitle',
        ),
        subtitle: context.tr(
          sub
              ? 'productSearch.noResultsSubcategorySubtitle'
              : 'productSearch.noResultsSearchSubtitle',
        ),
        primaryLabel: context.tr('productSearch.editSearch'),
        onPrimary: () {
          _searchController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _searchController.text.length,
          );
          _searchFocusNode.requestFocus();
        },
      );
    }

    return _results(
      context,
      allProducts: data.$1,
      totalElements: data.$2,
      loadingMore: data.$3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int cartCount = context.watch<CartBloc>().itemCount;

    return BlocListener<ProductSearchBloc, ProductSearchState>(
      listenWhen: (ProductSearchState previous, ProductSearchState current) {
        if (current is! ProductSearchLoaded || current.noticeKey == null) {
          return false;
        }
        return !(previous is ProductSearchLoaded &&
            previous.noticeKey == current.noticeKey);
      },
      listener: (BuildContext context, ProductSearchState state) {
        final String? key = (state as ProductSearchLoaded).noticeKey;
        if (key == null) return;
        AppSnackbars.info(context, context.tr(key));
        context.read<ProductSearchBloc>().add(ClearSearchNotice());
      },
      child: Scaffold(
        appBar: AppBarWidget(
          cartCount: cartCount,
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: !_hasInitialQuery(),
          searchPlaceholder: context.tr('productSearch.fieldHint'),
          onSearchSubmitted: (String _) {
            _performSearch();
            return null;
          },
          onCartTap: () =>
              NavigationService.instance.navigateToDashboardTab(context, 2),
        ),
        body: BlocBuilder<ProductSearchBloc, ProductSearchState>(
          builder: (BuildContext context, ProductSearchState state) {
            return AnimatedSwitcher(
              duration: AppMotion.fast,
              child: KeyedSubtree(
                key: ValueKey<Type>(state.runtimeType),
                child: _body(context, state),
              ),
            );
          },
        ),
      ),
    );
  }
}
