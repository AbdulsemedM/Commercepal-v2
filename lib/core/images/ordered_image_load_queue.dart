import 'dart:async';
import 'dart:collection';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Caps concurrent image downloads and serves waiting URLs in priority order
/// (lower [priority] starts first). Used so home product images fill
/// top-to-bottom / left-to-right instead of racing randomly.
class OrderedImageLoadQueue {
  OrderedImageLoadQueue({
    this.maxConcurrent = 3,
    BaseCacheManager? cacheManager,
  }) : _cacheManager = cacheManager ?? DefaultCacheManager();

  static final OrderedImageLoadQueue instance = OrderedImageLoadQueue();

  final int maxConcurrent;
  final BaseCacheManager _cacheManager;

  final SplayTreeMap<int, Queue<_QueuedImage>> _waitingByPriority =
      SplayTreeMap<int, Queue<_QueuedImage>>();
  final Map<String, _QueuedImage> _byUrl = <String, _QueuedImage>{};
  int _activeCount = 0;

  /// Returns when [url] may start downloading (or is already cached / active).
  /// Call [release] when the download finishes or the requester is disposed.
  /// Multiple holders of the same URL must each release.
  Future<void> acquire(String url, {required int priority}) {
    final String key = url.trim();
    if (key.isEmpty) {
      return Future<void>.value();
    }

    final _QueuedImage? existing = _byUrl[key];
    if (existing != null) {
      existing.holders++;
      if (priority < existing.priority) {
        _reprioritize(existing, priority);
      }
      return existing.completer.future;
    }

    final _QueuedImage entry = _QueuedImage(
      url: key,
      priority: priority,
      completer: Completer<void>(),
    );
    _byUrl[key] = entry;
    _enqueue(entry);
    _pump();
    return entry.completer.future;
  }

  /// Decrements holders for [url] and frees the concurrency slot the first
  /// time a started download is released.
  void release(String url) {
    final String key = url.trim();
    if (key.isEmpty) return;

    final _QueuedImage? entry = _byUrl[key];
    if (entry == null) return;

    entry.holders--;

    if (entry.started && !entry.slotFreed) {
      entry.slotFreed = true;
      _activeCount = (_activeCount - 1).clamp(0, maxConcurrent);
      _pump();
    }

    if (entry.holders > 0) return;

    _byUrl.remove(key);
    if (!entry.started) {
      _removeFromWaiting(key);
    }
  }

  /// Warm the queue in visual order so later ListView items still get
  /// priority even before they build.
  void prefetchOrdered(
    List<String> urls, {
    required int Function(int index) priorityForIndex,
  }) {
    for (var i = 0; i < urls.length; i++) {
      final String url = urls[i].trim();
      if (url.isEmpty) continue;
      final int priority = priorityForIndex(i);
      unawaited(() async {
        await acquire(url, priority: priority);
        try {
          await _cacheManager.getSingleFile(url);
        } catch (_) {
          // Best-effort prefetch; widgets will retry via CachedNetworkImage.
        } finally {
          release(url);
        }
      }());
    }
  }

  /// True when [url] is already present on disk (skip queue wait).
  Future<bool> isCached(String url) async {
    final String key = url.trim();
    if (key.isEmpty) return false;
    try {
      final FileInfo? info = await _cacheManager.getFileFromCache(key);
      return info != null && await info.file.exists();
    } catch (_) {
      return false;
    }
  }

  void _reprioritize(_QueuedImage entry, int newPriority) {
    if (entry.started || entry.priority == newPriority) return;
    _removeFromWaiting(entry.url);
    entry.priority = newPriority;
    _enqueue(entry);
  }

  void _enqueue(_QueuedImage entry) {
    _waitingByPriority
        .putIfAbsent(entry.priority, () => Queue<_QueuedImage>())
        .add(entry);
  }

  void _removeFromWaiting(String url) {
    final List<int> emptyKeys = <int>[];
    _waitingByPriority.forEach((int priority, Queue<_QueuedImage> queue) {
      queue.removeWhere((_QueuedImage e) => e.url == url);
      if (queue.isEmpty) emptyKeys.add(priority);
    });
    for (final int key in emptyKeys) {
      _waitingByPriority.remove(key);
    }
  }

  void _pump() {
    while (_activeCount < maxConcurrent) {
      final _QueuedImage? next = _takeNext();
      if (next == null) return;
      next.started = true;
      _activeCount++;
      if (!next.completer.isCompleted) {
        next.completer.complete();
      }
    }
  }

  _QueuedImage? _takeNext() {
    while (_waitingByPriority.isNotEmpty) {
      final int priority = _waitingByPriority.firstKey()!;
      final Queue<_QueuedImage> queue = _waitingByPriority[priority]!;
      while (queue.isNotEmpty) {
        final _QueuedImage entry = queue.removeFirst();
        if (_byUrl[entry.url] == entry && !entry.started) {
          if (queue.isEmpty) {
            _waitingByPriority.remove(priority);
          }
          return entry;
        }
      }
      _waitingByPriority.remove(priority);
    }
    return null;
  }
}

class _QueuedImage {
  _QueuedImage({
    required this.url,
    required this.priority,
    required this.completer,
  }) : holders = 1;

  final String url;
  int priority;
  final Completer<void> completer;
  int holders;
  bool started = false;
  bool slotFreed = false;
}
