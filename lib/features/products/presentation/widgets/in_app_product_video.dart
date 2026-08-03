import 'dart:async';

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

String _htmlEscapeAttrUrl(String url) {
  return url.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;');
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
  });

  final String url;
  final bool autoPlay;

  @override
  State<InAppProductVideo> createState() => _InAppProductVideoState();
}

class _InAppProductVideoState extends State<InAppProductVideo> {
  static const Duration _initTimeout = Duration(seconds: 30);

  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _fileController;
  WebViewController? _webFallbackController;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Avoid Android Pigeon "Unable to establish connection" when init runs before
    // the platform channel is ready, or when many players start at once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_init());
    });
  }

  Future<void> _init() async {
    final String normalized = normalizeVideoHttpUrl(widget.url);
    if (normalized.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Invalid video URL';
        });
      }
      return;
    }

    final String? youtubeId = extractYoutubeVideoId(normalized);
    if (youtubeId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          // Muted autoplay matches YouTube / WebView policies so playback actually starts.
          mute: widget.autoPlay,
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
        });
      }
      return;
    }

    // Stagger concurrent inits on product pages with multiple video tiles.
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
              'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
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
      if (widget.autoPlay) {
        await fileTry.play();
      }
      _fileController = fileTry;
      if (mounted) {
        setState(() {
          _loading = false;
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
  }

  void _openHtml5VideoInWebView(String videoUrl) {
    final Uri parsed = Uri.parse(videoUrl);
    final String origin = parsed.hasAuthority
        ? '${parsed.scheme}://${parsed.authority}'
        : 'https://localhost';
    final String safeSrc = _htmlEscapeAttrUrl(videoUrl);
    final String autoAttrs = widget.autoPlay
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
      // HTML5 <video> does not require JS; keep disabled to reduce XSS surface.
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final Uri? uri = Uri.tryParse(request.url);
            // Allow about:blank / data for the loaded HTML document.
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
        ),
      )
      ..loadHtmlString(html, baseUrl: origin);
    setState(() {
      _webFallbackController = c;
      _loading = false;
      _error = null;
    });
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
    final Uri? initial = Uri.tryParse(normalized);
    if (initial == null || !_isAllowedVideoNavigationUri(initial)) {
      setState(() {
        _loading = false;
        _error = 'Disallowed or insecure video URL';
      });
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
        ),
      )
      ..loadRequest(initial);
    setState(() {
      _webFallbackController = c;
      _loading = false;
      _error = null;
    });
  }

  @override
  void dispose() {
    _fileController?.removeListener(_fileListener);
    _fileController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    if (_error != null && _youtubeController == null && _webFallbackController == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Colors.grey.shade200,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      );
    }

    if (_youtubeController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: YoutubePlayer(
          controller: _youtubeController!,
          aspectRatio: 16 / 9,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (_webFallbackController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: WebViewWidget(controller: _webFallbackController!),
        ),
      );
    }

    final VideoPlayerController? c = _fileController;
    if (c == null || !c.value.isInitialized) {
      return const SizedBox.shrink();
    }

    if (c.value.hasError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Colors.grey.shade200,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                c.value.errorDescription ?? 'Playback error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
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
      ),
    );
  }
}
