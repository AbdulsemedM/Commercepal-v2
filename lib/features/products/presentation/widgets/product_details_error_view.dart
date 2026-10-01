import 'package:flutter/material.dart';

import 'package:commercepal/core/widgets/app_empty_state.dart';
import 'package:commercepal/services/localization_service.dart';

/// Product page error state, worded for the specific failure.
class ProductDetailsErrorView extends StatelessWidget {
  const ProductDetailsErrorView({
    super.key,
    required this.message,
    this.errorCode,
    required this.onRetry,
    this.onGoBack,
  });

  final String message;
  final String? errorCode;
  final VoidCallback onRetry;
  final VoidCallback? onGoBack;

  bool get _isTemporarilyUnavailable =>
      errorCode == 'PRODUCT_TEMPORARILY_UNAVAILABLE' || errorCode == '503';

  bool get _isNotFound =>
      errorCode == '404' || errorCode == 'PRODUCT_NOT_FOUND';

  bool get _isOffline =>
      message.toLowerCase().contains('internet') ||
      message.toLowerCase().contains('connection');

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String key) = _isTemporarilyUnavailable
        ? (Icons.schedule_rounded, 'product.error.pricing')
        : _isNotFound
            ? (Icons.search_off_rounded, 'product.error.notFound')
            : _isOffline
                ? (Icons.wifi_off_rounded, 'product.error.offline')
                : (Icons.error_outline_rounded, 'product.error.generic');

    return SingleChildScrollView(
      child: AppEmptyState(
        icon: icon,
        isError: !_isNotFound,
        title: context.tr('$key.title'),
        subtitle: context.tr('$key.hint'),
        // Retrying a removed listing is pointless; offer to go back instead.
        primaryLabel: _isNotFound ? null : context.tr('common.retry'),
        onPrimary: _isNotFound ? null : onRetry,
        secondaryLabel: onGoBack != null ? context.tr('common.goBack') : null,
        onSecondary: onGoBack,
      ),
    );
  }
}
