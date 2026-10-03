import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/core/widgets/checkout_screen_header.dart';
import 'package:commercepal/services/localization_service.dart';
import '../../bloc/payment_status_cubit.dart';
import '../widgets/payment_status_polling_banner.dart';

/// Allowed hosts for payment WebView (exact host or subdomain).
const Set<String> _allowedPaymentHostSuffixes = {
  'sahaypay.com',
  'telebirr.com',
  'ebirr.com',
  'pesapal.com',
  'paypal.com',
  'cbe.com.et',
  'commercepal.com',
  'ziina.com',
};

/// In-app WebView screen for completing payment at [paymentUrl].
class PaymentWebViewScreen extends StatelessWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    this.orderNumber,
    this.paymentProviderCode,
  });

  final String paymentUrl;
  final String? orderNumber;
  final String? paymentProviderCode;

  @override
  Widget build(BuildContext context) {
    final String? orderNum = orderNumber?.trim();
    if (orderNum != null && orderNum.isNotEmpty) {
      return BlocProvider(
        create: (_) => PaymentStatusCubit(),
        child: _PaymentWebViewBody(
          paymentUrl: paymentUrl,
          orderNumber: orderNum,
          paymentProviderCode: paymentProviderCode,
        ),
      );
    }
    return _PaymentWebViewBody(
      paymentUrl: paymentUrl,
      paymentProviderCode: paymentProviderCode,
    );
  }
}

class _PaymentWebViewBody extends StatefulWidget {
  const _PaymentWebViewBody({
    required this.paymentUrl,
    this.orderNumber,
    this.paymentProviderCode,
  });

  final String paymentUrl;
  final String? orderNumber;
  final String? paymentProviderCode;

  @override
  State<_PaymentWebViewBody> createState() => _PaymentWebViewBodyState();
}

class _PaymentWebViewBodyState extends State<_PaymentWebViewBody>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initWebView();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final String? orderNumber = widget.orderNumber?.trim();
    if (orderNumber == null || orderNumber.isEmpty || !mounted) return;
    context.read<PaymentStatusCubit>().checkNow();
  }

  void _initWebView() {
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
            final String url = request.url;
            if (url.contains('commercepal.com/checkout/success')) {
              return NavigationDecision.prevent;
            }
            if (url.contains('commercepal.com/checkout/cancel')) {
              return NavigationDecision.prevent;
            }
            if (!_isPaymentUrlAllowed(url)) {
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
            // A failing image/script/tracker on the provider's page must not
            // replace the whole payment page with an error.
            if (error.isForMainFrame == false) return;
            setState(() {
              _isLoading = false;
              _loadError = error.description.isNotEmpty
                  ? error.description
                  : 'Failed to load payment page';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

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

  @override
  Widget build(BuildContext context) {
    final String? orderNumber = widget.orderNumber?.trim();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            CheckoutScreenHeader(
              title: context.tr('checkout.completePayment'),
              trailing: Padding(
                padding: const EdgeInsetsDirectional.only(end: Spacing.sm),
                child: Tooltip(
                  message: context.tr('checkout.webview.secure'),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: AppSizes.iconMd,
                    color: theme.colorScheme.onSurfaceVariant,
                    semanticLabel: context.tr('checkout.webview.secure'),
                  ),
                ),
              ),
            ),
            if (orderNumber != null && orderNumber.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  Spacing.gutter,
                  0,
                  Spacing.gutter,
                  Spacing.sm,
                ),
                child: PaymentStatusPollingBanner(
                  orderNumber: orderNumber,
                  onSuccess: () => navigateOnPaymentStatusSuccess(
                    context,
                    clearCart: true,
                  ),
                ),
              ),
            Divider(height: 1, thickness: 1, color: context.commerce.border),
            Expanded(
              child: _loadError != null
                  ? _buildError(context)
                  : Stack(
                      children: <Widget>[
                        WebViewWidget(controller: _controller),
                        if (_isLoading) ...<Widget>[
                          PositionedDirectional(
                            top: 0,
                            start: 0,
                            end: 0,
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              color: theme.colorScheme.primary,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          Center(
                            child: Semantics(
                              liveRegion: true,
                              label: context.tr('checkout.webview.loading'),
                              child: const CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final bool blocked = !_isPaymentUrlAllowed(widget.paymentUrl);
    return SafeArea(
      top: false,
      child: AppEmptyState(
        isError: true,
        icon: blocked ? Icons.gpp_bad_outlined : Icons.cloud_off_outlined,
        title: context.tr(
          blocked
              ? 'checkout.webview.blockedTitle'
              : 'checkout.webview.errorTitle',
        ),
        subtitle: context.tr(
          blocked
              ? 'checkout.webview.blockedBody'
              : 'checkout.webview.errorBody',
        ),
        primaryLabel: context.tr('common.goBack'),
        onPrimary: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
