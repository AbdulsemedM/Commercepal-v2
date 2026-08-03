import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:commercepal/core/images/ordered_image_load_queue.dart';

/// Disk-cached network image with right-sized memory decode and optional
/// ordered load priority for home product grids.
class AppNetworkImage extends StatefulWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.loadPriority,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 180),
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  /// Lower values download sooner when using [OrderedImageLoadQueue].
  final int? loadPriority;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final BorderRadius? borderRadius;

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  bool _canLoad = false;
  bool _holdingSlot = false;
  String? _heldUrl;

  @override
  void initState() {
    super.initState();
    _prepareLoad();
  }

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.loadPriority != widget.loadPriority) {
      _releaseSlot();
      _canLoad = false;
      _prepareLoad();
    }
  }

  @override
  void dispose() {
    _releaseSlot();
    super.dispose();
  }

  Future<void> _prepareLoad() async {
    final String url = widget.url.trim();
    if (url.isEmpty) {
      if (mounted) setState(() => _canLoad = false);
      return;
    }

    final int? priority = widget.loadPriority;
    if (priority == null) {
      if (mounted) setState(() => _canLoad = true);
      return;
    }

    final OrderedImageLoadQueue queue = OrderedImageLoadQueue.instance;
    if (await queue.isCached(url)) {
      if (mounted) setState(() => _canLoad = true);
      return;
    }

    _heldUrl = url;
    _holdingSlot = true;
    try {
      await queue.acquire(url, priority: priority);
      if (!mounted || _heldUrl != url) {
        queue.release(url);
        _holdingSlot = false;
        _heldUrl = null;
        return;
      }
      if (mounted) setState(() => _canLoad = true);
    } catch (_) {
      _holdingSlot = false;
      _heldUrl = null;
      if (mounted) setState(() => _canLoad = true);
    }
  }

  void _releaseSlot() {
    if (!_holdingSlot || _heldUrl == null) return;
    OrderedImageLoadQueue.instance.release(_heldUrl!);
    _holdingSlot = false;
    _heldUrl = null;
  }

  void _onImageSettled() {
    // Free the concurrency slot once the image has resolved so later
    // priorities can start; disk/memory cache keeps the bytes.
    _releaseSlot();
  }

  int? _resolveMemCacheWidth(BuildContext context) {
    if (widget.memCacheWidth != null) return widget.memCacheWidth;
    final double? w = widget.width;
    if (w == null || !w.isFinite || w <= 0) return null;
    return (w * MediaQuery.devicePixelRatioOf(context)).round();
  }

  int? _resolveMemCacheHeight(BuildContext context) {
    if (widget.memCacheHeight != null) return widget.memCacheHeight;
    final double? h = widget.height;
    if (h == null || !h.isFinite || h <= 0) return null;
    return (h * MediaQuery.devicePixelRatioOf(context)).round();
  }

  Widget _defaultPlaceholder(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
    );
  }

  Widget _defaultError(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: scheme.onSurfaceVariant,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String url = widget.url.trim();
    final Widget placeholder = widget.placeholder ?? _defaultPlaceholder(context);
    final Widget error = widget.errorWidget ?? _defaultError(context);

    Widget child;
    if (url.isEmpty) {
      child = error;
    } else if (!_canLoad) {
      child = placeholder;
    } else {
      child = CachedNetworkImage(
        imageUrl: url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        memCacheWidth: _resolveMemCacheWidth(context),
        memCacheHeight: _resolveMemCacheHeight(context),
        fadeInDuration: widget.fadeInDuration,
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _onImageSettled();
          });
          return error;
        },
        imageBuilder: (BuildContext context, ImageProvider imageProvider) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _onImageSettled();
          });
          return Image(
            image: imageProvider,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            gaplessPlayback: true,
          );
        },
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }
    return child;
  }
}
