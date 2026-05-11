import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/app/router/app_router.dart';
import 'package:commercepal/features/wishlist/data/wishlist_item.dart';
import 'package:commercepal/features/wishlist/data/repository/wishlist_repository.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistRepository _repository = WishlistRepository();
  List<WishlistItem> _items = <WishlistItem>[];
  bool _loading = true;
  bool _loadingMore = false;
  int _currentPage = 0;
  bool _hasNextPage = false;

  Future<void> _loadItems() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _items = <WishlistItem>[];
      _currentPage = 0;
    });
    try {
      if (_repository.isLoggedIn) {
        final response = await _repository.getWishlistPage(0);
        if (mounted) {
          setState(() {
            _items = response.items.map(WishlistItem.fromProduct).toList();
            _hasNextPage = response.pagination.hasNext;
            _currentPage = 0;
            _loading = false;
          });
        }
      } else {
        final list = await _repository.getLocalWishlist();
        if (mounted) {
          setState(() {
            _items = list;
            _hasNextPage = false;
            _loading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_repository.isLoggedIn || !_hasNextPage || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final response = await _repository.getWishlistPage(nextPage);
      if (mounted) {
        setState(() {
          _items = <WishlistItem>[
            ..._items,
            ...response.items.map(WishlistItem.fromProduct),
          ];
          _hasNextPage = response.pagination.hasNext;
          _currentPage = nextPage;
          _loadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _removeItem(WishlistItem item) async {
    try {
      await _repository.removeItem(item.productId);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.t(context, 'wishlist.removeFailed'),
            ),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _items = _items.where((e) => e.productId != item.productId).toList();
    });
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          LocalizationService.t(context, 'wishlist.removedSnackbar'),
        ),
        action: SnackBarAction(
          label: LocalizationService.t(context, 'cart.undo'),
          onPressed: () async {
            try {
              await _repository.addItem(item);
              if (mounted) {
                setState(() {
                  if (!_items.any((WishlistItem e) => e.productId == item.productId)) {
                    _items = <WishlistItem>[..._items, item];
                  }
                });
              }
            } catch (_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      LocalizationService.t(context, 'wishlist.undoFailed'),
                    ),
                  ),
                );
              }
            }
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _openProduct(WishlistItem item) {
    context
        .push(
          '${AppRoutes.productDetail}?id=${Uri.encodeComponent(item.productId)}&name=${Uri.encodeComponent(item.productName)}',
        )
        .then((_) => _loadItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          LocalizationService.t(context, 'wishlist.title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.xl,
                        Spacing.xxl,
                        Spacing.xl,
                        Spacing.xl,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_outline,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          Text(
                            LocalizationService.t(context, 'wishlist.title'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            LocalizationService.t(context, 'wishlist.productsSaved'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: Spacing.xxl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: Spacing.lg),
                            Text(
                              LocalizationService.t(context, 'wishlist.empty'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              LocalizationService.t(context, 'wishlist.emptyHint'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (index == _items.length) {
                              if (!_hasNextPage) return const SizedBox.shrink();
                              if (_loadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(Spacing.md),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: Spacing.md),
                                child: Center(
                                  child: TextButton(
                                    onPressed: _loadMore,
                                    child: const Text('Load more'),
                                  ),
                                ),
                              );
                            }
                            final item = _items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Spacing.md),
                              child: _WishlistCard(
                                item: item,
                                onTap: () => _openProduct(item),
                                onRemove: () => _removeItem(item),
                              ),
                            );
                          },
                          childCount: _items.length + (_hasNextPage ? 1 : 0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final WishlistItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    item.productName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  onPressed: onRemove,
                  tooltip: LocalizationService.t(context, 'wishlist.removeTooltip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
