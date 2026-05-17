import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:commercepal/services/localization_service.dart';

/// CommercePal account deletion request (Google Form). Do not load arbitrary URLs.
const String kAccountDeletionFormUrl =
    'https://forms.gle/BUuT9py2WuyDRt177';

/// Hosts allowed for navigation after opening the account-deletion form (redirects, sign-in, assets).
bool _isAllowedAccountDeletionHost(String host) {
  final String h = host.toLowerCase();
  if (h == 'forms.gle') return true;
  if (h == 'docs.google.com') return true;
  if (h == 'accounts.google.com') return true;
  if (h == 'myaccount.google.com') return true;
  if (h == 'www.google.com') return true;
  if (h == 'consent.google.com') return true;
  if (h == 'policies.google.com') return true;
  if (h == 'support.google.com') return true;
  if (h == 'gstatic.com' || h.endsWith('.gstatic.com')) return true;
  if (h == 'googleusercontent.com' || h.endsWith('.googleusercontent.com')) {
    return true;
  }
  if (h.endsWith('.googleapis.com')) return true;
  return false;
}

bool _isAllowedAccountDeletionNavigationUri(Uri uri) {
  if (!uri.hasScheme || uri.scheme.toLowerCase() != 'https') return false;
  if (uri.host.isEmpty) return false;
  return _isAllowedAccountDeletionHost(uri.host);
}

bool _isInitialFormUrlConfigured() {
  final Uri? uri = Uri.tryParse(kAccountDeletionFormUrl);
  if (uri == null) return false;
  return _isAllowedAccountDeletionNavigationUri(uri);
}

/// In-app WebView for the account deletion request form.
class AccountDeletionRequestScreen extends StatefulWidget {
  const AccountDeletionRequestScreen({super.key});

  @override
  State<AccountDeletionRequestScreen> createState() =>
      _AccountDeletionRequestScreenState();
}

class _AccountDeletionRequestScreenState
    extends State<AccountDeletionRequestScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _loadError;

  static const String _browserUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  @override
  void initState() {
    super.initState();
    if (!_isInitialFormUrlConfigured()) {
      _loadError = '__config__';
      _isLoading = false;
      _controller = WebViewController();
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final Uri? uri = Uri.tryParse(request.url);
            if (uri == null || !_isAllowedAccountDeletionNavigationUri(uri)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _loadError = error.description.isNotEmpty
                  ? error.description
                  : 'Could not load the page (${error.errorCode}).';
            });
          },
        ),
      );
    _loadForm();
  }

  Future<void> _loadForm() async {
    await _controller.setUserAgent(_browserUserAgent);
    if (!mounted) return;
    await _controller.loadRequest(Uri.parse(kAccountDeletionFormUrl));
  }

  String _errorBodyText(BuildContext context) {
    if (_loadError == '__config__') {
      return LocalizationService.t(
        context,
        'profile.accountDeletionLoadError',
      );
    }
    return _loadError ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final String title = LocalizationService.t(
      context,
      'profile.accountDeletionRequestTitle',
    );

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorBodyText(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (_loadError == '__config__')
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      LocalizationService.t(context, 'profile.cancel'),
                    ),
                  )
                else
                  FilledButton(
                    onPressed: () {
                      setState(() => _loadError = null);
                      _loadForm();
                    },
                    child: Text(
                      LocalizationService.t(context, 'cart.retry'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: LocalizationService.t(
              context,
              'profile.accountDeletionOpenInBrowser',
            ),
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final Uri uri = Uri.parse(kAccountDeletionFormUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_isLoading) const LinearProgressIndicator(minHeight: 3),
          Expanded(
            child: Stack(
              children: <Widget>[
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
