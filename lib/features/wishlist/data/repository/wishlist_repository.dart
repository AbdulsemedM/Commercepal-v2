import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/features/wishlist/data/data_provider/wishlist_data_provider.dart';
import 'package:commercepal/features/wishlist/data/models/wishlist_response.dart';
import 'package:commercepal/features/wishlist/data/wishlist_item.dart';
import 'package:commercepal/services/auth_service.dart';

/// Coordinates wishlist between local storage and backend.
/// When logged in: reads from API, writes to both local and API.
/// When not logged in: uses only local storage.
class WishlistRepository {
  WishlistRepository({
    WishlistDataProvider? dataProvider,
    AuthService? authService,
  })  : _dataProvider = dataProvider ?? WishlistDataProvider(),
        _authService = authService ?? AuthService();

  final WishlistDataProvider _dataProvider;
  final AuthService _authService;

  bool get isLoggedIn => _authService.isLoggedIn;

  /// Get paginated wishlist from API. Use only when [isLoggedIn] is true.
  Future<WishlistResponse> getWishlistPage(int page) async {
    return _dataProvider.getWishlist(page: page);
  }

  /// Get full wishlist from local storage (for guest users).
  Future<List<WishlistItem>> getLocalWishlist() async {
    return Storage().getWishlist();
  }

  /// Add item to wishlist. Updates local storage; if logged in, syncs IDs to backend.
  Future<void> addItem(WishlistItem item) async {
    final storage = Storage();
    await storage.addWishlistItem(item);
    if (_authService.isLoggedIn) {
      final ids = await _getLocalIds(storage);
      await _dataProvider.syncWishlist(ids);
    }
  }

  /// Remove item from wishlist. Updates local storage; if logged in, calls remove API.
  Future<void> removeItem(String productId) async {
    final storage = Storage();
    await storage.removeWishlistItem(productId);
    if (_authService.isLoggedIn) {
      await _dataProvider.removeFromWishlist(<String>[productId]);
    }
  }

  /// Clear wishlist. Clears local storage; if logged in, calls clear API.
  Future<void> clearWishlist() async {
    final storage = Storage();
    await storage.clearWishlist();
    if (_authService.isLoggedIn) {
      await _dataProvider.clearWishlist();
    }
  }

  /// Sync local wishlist product IDs to backend. Call after login.
  Future<void> syncLocalToBackend() async {
    if (!_authService.isLoggedIn) return;
    final storage = Storage();
    final ids = await _getLocalIds(storage);
    if (ids.isEmpty) return;
    AppLogger.i('Syncing ${ids.length} wishlist item(s) to backend');
    await _dataProvider.syncWishlist(ids);
  }

  Future<List<String>> _getLocalIds(Storage storage) async {
    final list = await storage.getWishlist();
    return list.map((e) => e.productId).toList();
  }
}
