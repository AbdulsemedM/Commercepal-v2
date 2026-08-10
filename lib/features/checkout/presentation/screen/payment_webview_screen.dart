import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:commercepal/services/localization_service.dart';
import '../../../../app/router/app_router.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../bloc/payment_status_cubit.dart';
import '../../data/models/payment_constants.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.t(context, 'checkout.completePayment')),
      ),
      body: Column(
        children: <Widget>[
          if (orderNumber != null && orderNumber.isNotEmpty)
            PaymentStatusPollingBanner(
              orderNumber: orderNumber,
              onSuccess: () => navigateOnPaymentStatusSuccess(
                context,
                clearCart: true,
              ),
            ),
          Expanded(
            child: _loadError != null
                ? Center(child: Text(_loadError!))
                : Stack(
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
