import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Normalizes bare hosts to https. Rejects cleartext http (upgrade or leave empty).
String normalizeVideoHttpUrl(String url) {
  final String t = url.trim();
  if (t.isEmpty) return t;
  final String lower = t.toLowerCase();
  if (lower.startsWith('https://')) return t;
  if (lower.startsWith('http://')) {
    return 'https://${t.substring(7)}';
  }
  return 'https://$t';
}

bool _isAllowedVideoNavigationHost(String host) {
  final String h = host.toLowerCase();
  if (h.isEmpty) return false;
  const Set<String> allowed = <String>{
    'youtube.com',
    'youtu.be',
    'youtube-nocookie.com',
    'googlevideo.com',
    'ytimg.com',
    'gstatic.com',
    'commercepal.com',
    'amazonaws.com',
    'cloudfront.net',
    'aliyuncs.com',
  };
  for (final String suffix in allowed) {
    if (h == suffix || h.endsWith('.$suffix')) return true;
  }
  return false;
}

bool _isAllowedVideoNavigationUri(Uri uri) {
  if (!uri.hasScheme || uri.scheme.toLowerCase() != 'https') return false;
  return _isAllowedVideoNavigationHost(uri.host);
}

/// YouTube video ids are 11 chars ([0-9A-Za-z_-]).
String? sanitizeYoutubeVideoId(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final String t = raw.trim();
  if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(t)) return t;
  final RegExpMatch? m = RegExp(r'[a-zA-Z0-9_-]{11}').firstMatch(t);
  return m?.group(0);
}

/// Extracts a YouTube video id from common URL shapes.
String? extractYoutubeVideoId(String rawUrl) {
  final String url = normalizeVideoHttpUrl(rawUrl);
  final Uri? uri = Uri.tryParse(url);
  if (uri == null) return null;

  final host = uri.host.toLowerCase();
  final isYt = host.contains('youtube.com') ||
      host.contains('youtu.be') ||
      host.contains('youtube-nocookie.com');
  if (!isYt) return null;

  if (host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
    return sanitizeYoutubeVideoId(uri.pathSegments.first);
  }

  final v = uri.queryParameters['v'];
  if (v != null && v.isNotEmpty) {
    return sanitizeYoutubeVideoId(v);
  }

  final segments = uri.pathSegments;
  if (segments.length >= 2 && segments[0] == 'embed') {
    return sanitizeYoutubeVideoId(segments[1]);
  }
  if (segments.length >= 2 && segments[0] == 'shorts') {
    return sanitizeYoutubeVideoId(segments[1]);
  }
  if (segments.length >= 2 && segments[0] == 'live') {
    return sanitizeYoutubeVideoId(segments[1]);
  }

  return null;
}

/// Android: avoid `video_player` ExoPlayer bridge (Pigeon channel errors in some builds).
bool _useNativeFileVideoPlayer() {
  if (kIsWeb) return true;
  return defaultTargetPlatform != TargetPlatform.android;
}

/// iOS WKWebView / AVPlayer autoplay has caused hangs and crashes on some devices.
bool _isIosPlatform() {
  return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}

String _htmlEscapeAttrUrl(String url) {
  return url
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll('<', '&lt;');
}

Widget _videoUnavailablePlaceholder(BuildContext context, [String? message]) {
  return AspectRatio(
    aspectRatio: 16 / 9,
    child: ColoredBox(
      color: Colors.grey.shade200,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.videocam_off_outlined, color: Colors.grey.shade600),
              const SizedBox(height: 8),
              Text(
                message ?? 'Video unavailable',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _tapToPlayPlaceholder(BuildContext context, {required VoidCallback onPlay}) {
  return AspectRatio(
    aspectRatio: 16 / 9,
    child: Material(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPlay,
        child: const Center(
          child: Icon(
            Icons.play_circle_fill,
            size: 64,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

/// Isolates player failures so a broken video tile cannot take down the PDP.
class SoftFailProductVideo extends StatefulWidget {
  const SoftFailProductVideo({
    super.key,
    required this.url,
    this.autoPlay = false,
  });

  final String url;
  final bool autoPlay;

  @override
  State<SoftFailProductVideo> createState() => _SoftFailProductVideoState();
}

class _SoftFailProductVideoState extends State<SoftFailProductVideo> {
  bool _failed = false;

  void _reportFatal(Object error, StackTrace stack) {
    // Non-fatal: keep PDP usable; tag for Crashlytics iOS triage.
    unawaited(() async {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: false,
          reason: 'pdp_video_soft_fail',
        );
      } catch (_) {}
    }());
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _videoUnavailablePlaceholder(context);
    }
    try {
      return InAppProductVideo(
        url: widget.url,
        // Never autoplay on iOS — tap-to-start avoids WKWebView / AVPlayer hangs.
        autoPlay: _isIosPlatform() ? false : widget.autoPlay,
        onFatalError: () {
          if (mounted) setState(() => _failed = true);
        },
      );
    } catch (e, st) {
      _reportFatal(e, st);
      return _videoUnavailablePlaceholder(context);
    }
  }
}

/// In-app playback: [YoutubePlayer] for YouTube; [VideoPlayer] for direct files
/// on iOS/desktop/web. On **Android**, the native video_player plugin is skipped
/// (avoids recurring Pigeon `channel-error` on initialize) and direct URLs use
/// an HTML5 [&lt;video&gt;] inside [WebView] instead.
class InAppProductVideo extends StatefulWidget {
  const InAppProductVideo({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.onFatalError,
  });

  final String url;
  final bool autoPlay;
  final VoidCallback? onFatalError;

  @override
  State<InAppProductVideo> createState() => _InAppProductVideoState();
}

class _InAppProductVideoState extends State<InAppProductVideo> {
  static const Duration _initTimeout = Duration(seconds: 30);

  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _fileController;
  WebViewController? _webFallbackController;
  bool _loading = true;
  bool _awaitingUserTap = false;
  String? _error;

  /// Effective autoplay: always off on iOS.
  bool get _effectiveAutoPlay =>
      !_isIosPlatform() && widget.autoPlay;

  @override
  void initState() {
    super.initState();
    // On iOS, defer player creation until the user taps play so opening the
    // PDP never instantiates WKWebView/AVPlayer for every product with videos.
    if (_isIosPlatform()) {
      _loading = false;
      _awaitingUserTap = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_init());
    });
  }

  void _onUserTapPlay() {
    if (!_awaitingUserTap) return;
    setState(() {
      _awaitingUserTap = false;
      _loading = true;
      _error = null;
    });
    unawaited(_init());
  }

  void _markUnavailable([String message = 'Video unavailable']) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _awaitingUserTap = false;
      _error = message;
      _youtubeController = null;
      _webFallbackController = null;
    });
  }

  Future<void> _init() async {
    try {
      final String normalized = normalizeVideoHttpUrl(widget.url);
      if (normalized.isEmpty) {
        _markUnavailable('Invalid video URL');
        return;
      }

      final String? youtubeId = extractYoutubeVideoId(normalized);
      if (youtubeId != null) {
        try {
          _youtubeController = YoutubePlayerController(
            initialVideoId: youtubeId,
            flags: YoutubePlayerFlags(
              autoPlay: _effectiveAutoPlay,
              mute: _effectiveAutoPlay,
              loop: false,
              isLive: false,
              forceHD: false,
              enableCaption: false,
              controlsVisibleAtStart: true,
              hideControls: false,
              showLiveFullscreenButton: true,
            ),
          );
          if (mounted) {
            setState(() {
              _loading = false;
              _error = null;
            });
          }
        } catch (_) {
          _markUnavailable();
        }
        return;
      }

      if (!_useNativeFileVideoPlayer()) {
        _openHtml5VideoInWebView(normalized);
        return;
      }

      await Future<void>.delayed(
        Duration(milliseconds: 60 + (normalized.hashCode.abs() % 340)),
      );
      if (!mounted) return;

      VideoPlayerController? fileTry;
      try {
        fileTry = VideoPlayerController.networkUrl(
          Uri.parse(normalized),
          httpHeaders: const <String, String>{
            'User-Agent':
                'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
          },
        );
        await fileTry.initialize().timeout(_initTimeout);
        if (!mounted) {
          await fileTry.dispose();
          return;
        }
        if (fileTry.value.hasError) {
          throw Exception(fileTry.value.errorDescription ?? 'Playback error');
        }
        await fileTry.setLooping(false);
        fileTry.addListener(_fileListener);
        if (_effectiveAutoPlay) {
          await fileTry.play();
        }
        _fileController = fileTry;
        if (mounted) {
          setState(() {
            _loading = false;
            _error = null;
          });
        }
      } on PlatformException catch (_) {
        await fileTry?.dispose();
        if (!mounted) return;
        _openWebFallback(normalized);
      } on TimeoutException {
        await fileTry?.dispose();
        if (!mounted) return;
        _openWebFallback(normalized);
      } catch (_) {
        await fileTry?.dispose();
        if (!mounted) return;
        _openWebFallback(normalized);
      }
    } catch (_) {
      _markUnavailable();
    }
  }

  void _openHtml5VideoInWebView(String videoUrl) {
    try {
      final Uri parsed = Uri.parse(videoUrl);
      final String origin = parsed.hasAuthority
          ? '${parsed.scheme}://${parsed.authority}'
          : 'https://localhost';
      final String safeSrc = _htmlEscapeAttrUrl(videoUrl);
      final String autoAttrs = _effectiveAutoPlay
          ? ' autoplay muted playsinline'
          : ' playsinline';
      final String html = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1"/>
<style>
html,body{margin:0;padding:0;background:#000;height:100%;}
video{width:100%;height:100%;object-fit:contain;}
</style>
</head>
<body>
<video$autoAttrs controls crossorigin="anonymous" style="width:100%;height:100%;">
  <source src="$safeSrc">
</video>
</body>
</html>''';

      final WebViewController c = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.disabled)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              final Uri? uri = Uri.tryParse(request.url);
              if (uri == null) return NavigationDecision.prevent;
              final String scheme = uri.scheme.toLowerCase();
              if (scheme == 'about' || scheme == 'data') {
                return NavigationDecision.navigate;
              }
              if (!_isAllowedVideoNavigationUri(uri)) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageFinished: (_) {
              if (mounted) setState(() {});
            },
            onWebResourceError: (_) {
              if (mounted) {
                setState(() {
                  _error = 'Video unavailable';
                });
              }
            },
          ),
        )
        ..loadHtmlString(html, baseUrl: origin);
      if (!mounted) return;
      setState(() {
        _webFallbackController = c;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      _markUnavailable();
    }
  }

  void _fileListener() {
    final VideoPlayerController? c = _fileController;
    if (c == null || !mounted) return;
    if (c.value.hasError) {
      setState(() {
        _error = c.value.errorDescription ?? 'Could not play video';
      });
    } else {
      setState(() {});
    }
  }

  void _openWebFallback(String normalized) {
    try {
      final Uri? initial = Uri.tryParse(normalized);
      if (initial == null || !_isAllowedVideoNavigationUri(initial)) {
        _markUnavailable('Disallowed or insecure video URL');
        return;
      }
      final WebViewController c = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              final Uri? uri = Uri.tryParse(request.url);
              if (uri == null || !_isAllowedVideoNavigationUri(uri)) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageFinished: (_) {
              if (mounted) setState(() {});
            },
            onWebResourceError: (_) {
              if (mounted) {
                setState(() {
                  _error = 'Video unavailable';
                });
              }
            },
          ),
        )
        ..loadRequest(initial);
      if (!mounted) return;
      setState(() {
        _webFallbackController = c;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      _markUnavailable();
    }
  }

  @override
  void dispose() {
    _fileController?.removeListener(_fileListener);
    _fileController?.dispose();
    try {
      _youtubeController?.dispose();
    } catch (_) {
      // Ignore dispose races from the YouTube plugin on iOS.
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildContent(context),
      );
    } catch (_) {
      widget.onFatalError?.call();
      return _videoUnavailablePlaceholder(context);
    }
  }

  Widget _buildContent(BuildContext context) {
    if (_awaitingUserTap) {
      return _tapToPlayPlaceholder(context, onPlay: _onUserTapPlay);
    }

    if (_loading) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Colors.black12,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null &&
        _youtubeController == null &&
        _webFallbackController == null) {
      return _videoUnavailablePlaceholder(context, _error);
    }

    if (_youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        aspectRatio: 16 / 9,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).colorScheme.primary,
      );
    }

    if (_webFallbackController != null) {
      if (_error != null) {
        return _videoUnavailablePlaceholder(context, _error);
      }
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: WebViewWidget(controller: _webFallbackController!),
      );
    }

    final VideoPlayerController? c = _fileController;
    if (c == null || !c.value.isInitialized) {
      return _videoUnavailablePlaceholder(context);
    }

    if (c.value.hasError) {
      return _videoUnavailablePlaceholder(
        context,
        c.value.errorDescription ?? 'Playback error',
      );
    }

    return AspectRatio(
      aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
      child: GestureDetector(
        onTap: () {
          if (c.value.isPlaying) {
            c.pause();
          } else {
            c.play();
          }
          setState(() {});
        },
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            VideoPlayer(c),
            if (!c.value.isPlaying)
              Container(
                color: Colors.black26,
                child: const Icon(
                  Icons.play_circle_fill,
                  size: 56,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
