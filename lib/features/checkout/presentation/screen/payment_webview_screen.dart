import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:commercepal/services/localization_service.dart';
import '../../../../app/router/app_router.dart';

/// In-app WebView screen for completing payment at [paymentUrl].
/// [orderNumber] is optional and can be shown in the AppBar.
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

  @override
  void initState() {
    super.initState();
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
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.orderNumber != null
        ? '${LocalizationService.t(context, 'checkout.order')} ${widget.orderNumber} – ${LocalizationService.t(context, 'checkout.orderCompletePayment')}'
        : LocalizationService.t(context, 'checkout.orderCompletePayment');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.dashboard);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
