import 'package:dio/dio.dart';

import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/services/api_service.dart';
import '../models/wishlist_response.dart';

class WishlistDataProvider {
  WishlistDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _endpoint = '/api/v1/wishlist';
  static const String _clearEndpoint = '/api/v1/wishlist/clear';

  /// Sync wishlist with backend: POST /api/v1/wishlist with list of product IDs.
  Future<void> syncWishlist(List<String> productIds) async {
    try {
      await _apiService.post<Map<String, dynamic>>(
        _endpoint,
        data: productIds,
      );
    } on DioException catch (e) {
      AppLogger.e('Sync wishlist failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during sync wishlist',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  /// Get wishlist: GET /api/v1/wishlist?page=0
  Future<WishlistResponse> getWishlist({int page = 0}) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        _endpoint,
        query: <String, dynamic>{'page': page},
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid response from server',
        );
      }

      return WishlistResponse.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.e('Get wishlist failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during get wishlist',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  /// Clear wishlist: POST /api/v1/wishlist/clear
  Future<void> clearWishlist() async {
    try {
      await _apiService.post<Map<String, dynamic>>(_clearEndpoint);
    } on DioException catch (e) {
      AppLogger.e('Clear wishlist failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during clear wishlist',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  /// Remove items from wishlist: DELETE /api/v1/wishlist with body ["id1", "id2"]
  Future<void> removeFromWishlist(List<String> productIds) async {
    if (productIds.isEmpty) return;
    try {
      await _apiService.delete<Map<String, dynamic>>(
        _endpoint,
        data: productIds,
      );
    } on DioException catch (e) {
      AppLogger.e('Remove from wishlist failed', error: e, stack: e.stackTrace);
      rethrow;
    } catch (e, stack) {
      AppLogger.e(
        'Unexpected error during remove from wishlist',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }
}
