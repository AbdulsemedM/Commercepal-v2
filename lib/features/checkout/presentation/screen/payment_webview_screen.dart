import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:commercepal/services/localization_service.dart';
import '../../../../app/router/app_router.dart';

/// Allowed host suffixes for payment WebView (backend must only return URLs for these).
/// Add your payment gateway domains (e.g. sahaypay, telebirr, cbe birr) to reduce open-redirect risk.
const Set<String> _allowedPaymentHostSuffixes = {
  'sahaypay.com',
  'sahaypay.',
  'telebirr.',
  'ebirr.',
  'pesapal.',
  'cbe.com.et', // CBE Birr payment gateway
};

/// In-app WebView screen for completing payment at [paymentUrl].
/// [orderNumber] is optional and can be shown in the AppBar.
/// Only HTTPS URLs are loaded; empty or invalid URLs show an error and do not load.
class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    this.orderNumber,
  });

  final String paymentUrl;
  final String? orderNumber;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _loadError;

  static bool _isPaymentUrlAllowed(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.scheme.toLowerCase() != 'https') {
      return false;
    }
    final host = uri.host.toLowerCase();
    if (host.isEmpty) return false;
    for (final suffix in _allowedPaymentHostSuffixes) {
      if (host == suffix || host.endsWith('.$suffix')) return true;
    }
    return false;
  }

  /// Browser-like User-Agent so payment gateways (e.g. CBE Birr) that block WebView accept the request.
  static const String _browserUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  @override
  void initState() {
    super.initState();
    if (!_isPaymentUrlAllowed(widget.paymentUrl)) {
      _loadError = 'Invalid or disallowed payment URL';
      _isLoading = false;
      _controller = WebViewController();
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
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
                  : 'Could not load the payment page (${error.errorCode}).';
            });
          },
        ),
      );
    _loadPaymentUrl();
  }

  Future<void> _loadPaymentUrl() async {
    await _controller.setUserAgent(_browserUserAgent);
    if (!mounted) return;
    await _controller.loadRequest(Uri.parse(widget.paymentUrl.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.orderNumber != null
        ? '${LocalizationService.t(context, 'checkout.order')} ${widget.orderNumber} – ${LocalizationService.t(context, 'checkout.orderCompletePayment')}'
        : LocalizationService.t(context, 'checkout.orderCompletePayment');

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  child: const Text('Go back'),
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
          onPressed: () {
            context.go(AppRoutes.dashboard);
          },
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final uri = Uri.tryParse(widget.paymentUrl.trim());
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 3),
          Expanded(
            child: _loadError != null
                ? Center(
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
                            _loadError!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () {
                              setState(() => _loadError = null);
                              _loadPaymentUrl();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: <Widget>[
                      WebViewWidget(controller: _controller),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
