import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:commercepal/services/localization_service.dart';
import '../../../../app/router/app_router.dart';
import '../../bloc/payment_status_cubit.dart';
import '../widgets/payment_status_polling_banner.dart';

/// Allowed hosts for payment WebView (exact host or subdomain).
/// Backend must only return URLs for these gateways.
const Set<String> _allowedPaymentHostSuffixes = {
  'sahaypay.com',
  'telebirr.com',
  'ebirr.com',
  'pesapal.com',
  'paypal.com',
  'cbe.com.et',
  'commercepal.com',
};

/// In-app WebView screen for completing payment at [paymentUrl].
class PaymentWebViewScreen extends StatelessWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    this.orderNumber,
  });

  final String paymentUrl;
  final String? orderNumber;

  @override
  Widget build(BuildContext context) {
    final String? orderNum = orderNumber?.trim();
    if (orderNum != null && orderNum.isNotEmpty) {
      return BlocProvider(
        create: (_) => PaymentStatusCubit(),
        child: _PaymentWebViewBody(
          paymentUrl: paymentUrl,
          orderNumber: orderNum,
        ),
      );
    }
    return _PaymentWebViewBody(paymentUrl: paymentUrl);
  }
}

class _PaymentWebViewBody extends StatefulWidget {
  const _PaymentWebViewBody({
    required this.paymentUrl,
    this.orderNumber,
  });

  final String paymentUrl;
  final String? orderNumber;

  @override
  State<_PaymentWebViewBody> createState() => _PaymentWebViewBodyState();
}

class _PaymentWebViewBodyState extends State<_PaymentWebViewBody> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _loadError;

  static bool _isHostAllowed(String host) {
    final String h = host.toLowerCase();
    if (h.isEmpty) return false;
    for (final String suffix in _allowedPaymentHostSuffixes) {
      if (h == suffix || h.endsWith('.$suffix')) return true;
    }
    return false;
  }

  static bool _isPaymentUrlAllowed(String url) {
    final String trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.scheme.toLowerCase() != 'https') {
      return false;
    }
    return _isHostAllowed(uri.host);
  }

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
          onNavigationRequest: (NavigationRequest request) {
            if (!_isPaymentUrlAllowed(request.url)) {
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
              children: <Widget>[
                const Icon(Icons.warning_amber_rounded,
                    size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  child: Text(
                    LocalizationService.t(context, 'checkout.continueShopping'),
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
          onPressed: () => context.go(AppRoutes.dashboard),
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
          if (widget.orderNumber != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: PaymentStatusPollingBanner(
                orderNumber: widget.orderNumber!,
                onSuccess: () => navigateOnPaymentStatusSuccess(context),
              ),
            ),
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
