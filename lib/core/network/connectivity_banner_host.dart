import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:commercepal/services/localization_service.dart';

/// Shows a compact banner when there is no network connection.
class ConnectivityBannerHost extends StatefulWidget {
  const ConnectivityBannerHost({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityBannerHost> createState() =>
      _ConnectivityBannerHostState();
}

class _ConnectivityBannerHostState extends State<ConnectivityBannerHost> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult> _results = <ConnectivityResult>[
    ConnectivityResult.none,
  ];

  static bool _isOnline(List<ConnectivityResult> results) {
    return results.any((ConnectivityResult r) => r != ConnectivityResult.none);
  }

  @override
  void initState() {
    super.initState();
    _refresh();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (mounted) {
          setState(() => _results = results);
        }
      },
    );
  }

  Future<void> _refresh() async {
    final List<ConnectivityResult> next = await _connectivity.checkConnectivity();
    if (mounted) {
      setState(() => _results = next);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool online = _isOnline(_results);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!online)
          Material(
            color: Colors.red.shade800,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Text(
                  LocalizationService.t(context, 'app.offlineMessage'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
