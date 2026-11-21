import 'dart:convert';

import 'package:commercepal/core/storage/storage.dart';

/// Phone checkout without a login code ("express checkout").
///
/// The backend issues a checkout-only token (`scope=EXPRESS_CHECKOUT`, 3 h, no
/// refresh token) from `/api/express-checkout/session`. It can only create the
/// delivery address, place and pay for orders, and read orders placed in this
/// session — never the profile, saved addresses, order history or wallet.
///
/// The token is kept apart from the normal session: the app does NOT treat the
/// shopper as signed in, and [AuthInterceptor] attaches it only to the
/// requests listed in [isAllowedRequest] (mirrors the backend allowlist).
class ExpressCheckout {
  ExpressCheckout._();

  static final ExpressCheckout instance = ExpressCheckout._();

  static const String _storageKey = 'express_checkout_session';

  /// Marks a request that carried the express token (see AuthInterceptor).
  static const String requestExtraKey = 'expressCheckout';

  String? _token;
  DateTime? _expiresAt;
  String? _phoneNumber;
  String? _firstName;
  bool _loaded = false;

  /// Delivery addresses created during this session (the account's saved
  /// addresses are never listed for an express shopper).
  final List<Map<String, dynamic>> _sessionAddresses = <Map<String, dynamic>>[];

  /// Orders placed during this session, newest first. An express token may read
  /// these (and only these), so My Orders can show them instead of an error.
  final List<String> _orderNumbers = <String>[];

  String? get phoneNumber => _phoneNumber;
  String? get firstName => _firstName;

  /// Active, with a minute of margin so a payment never starts on a dying token.
  bool get isActive =>
      _token != null &&
      _expiresAt != null &&
      _expiresAt!.isAfter(DateTime.now().add(const Duration(minutes: 1)));

  String? get token => isActive ? _token : null;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final String? raw = await Storage().readData(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      _token = json['token'] as String?;
      final int? expiresAtMs = (json['expiresAt'] as num?)?.toInt();
      _expiresAt = expiresAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
      _phoneNumber = json['phoneNumber'] as String?;
      _firstName = json['firstName'] as String?;
      final Object? addresses = json['addresses'];
      if (addresses is List) {
        _sessionAddresses
          ..clear()
          ..addAll(addresses.whereType<Map<String, dynamic>>());
      }
      final Object? orders = json['orders'];
      if (orders is List) {
        _orderNumbers
          ..clear()
          ..addAll(orders.whereType<String>());
      }
      if (!isActive) await clear();
    } catch (_) {
      await clear();
    }
  }

  Future<void> start({
    required String token,
    required int expiresInSeconds,
    required String phoneNumber,
    required String firstName,
  }) async {
    _token = token;
    _expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    _phoneNumber = phoneNumber;
    _firstName = firstName;
    _sessionAddresses.clear();
    _orderNumbers.clear();
    _loaded = true;
    await _persist();
  }

  List<String> get orderNumbers => List<String>.unmodifiable(_orderNumbers);

  Future<void> rememberOrder(String orderNumber) async {
    final String n = orderNumber.trim();
    if (n.isEmpty) return;
    _orderNumbers
      ..remove(n)
      ..insert(0, n);
    await _persist();
  }

  List<Map<String, dynamic>> get sessionAddresses =>
      List<Map<String, dynamic>>.unmodifiable(_sessionAddresses);

  Future<void> rememberAddress(Map<String, dynamic> addressJson) async {
    _sessionAddresses.removeWhere((Map<String, dynamic> a) => a['id'] == addressJson['id']);
    _sessionAddresses.add(addressJson);
    await _persist();
  }

  Future<void> forgetAddress(int id) async {
    _sessionAddresses.removeWhere((Map<String, dynamic> a) => a['id'] == id);
    await _persist();
  }

  Future<void> clear() async {
    _token = null;
    _expiresAt = null;
    _phoneNumber = null;
    _firstName = null;
    _sessionAddresses.clear();
    _orderNumbers.clear();
    try {
      await Storage().deleteData(_storageKey);
    } catch (_) {
      // Best effort.
    }
  }

  Future<void> _persist() async {
    await Storage().writeData(
      key: _storageKey,
      value: jsonEncode(<String, dynamic>{
        'token': _token,
        'expiresAt': _expiresAt?.millisecondsSinceEpoch,
        'phoneNumber': _phoneNumber,
        'firstName': _firstName,
        'addresses': _sessionAddresses,
        'orders': _orderNumbers,
      }),
    );
  }

  static const String _order = r'[A-Za-z0-9_-]{4,64}';

  static final List<_Rule> _rules = <_Rule>[
    _Rule('POST', RegExp(r'^/api/customers/addresses/?$')),
    _Rule('POST', RegExp(r'^/api/orders/checkout/?$')),
    _Rule('POST', RegExp(r'^/api/orders/checkout/preview/?$')),
    _Rule('GET', RegExp(r'^/api/payment-methods/?$')),
    _Rule('POST', RegExp(r'^/api/payments/paypal/create-order/?$')),
    _Rule('POST', RegExp(r'^/api/payments/telebirr/ussd/initiate/?$')),
    _Rule('POST', RegExp(r'^/api/payments/sahay/initiate-ussd/?$')),
    _Rule('GET', RegExp(r'^/api/payments/sahaypay/customer-lookup/?$')),
    _Rule('POST', RegExp(r'^/api/payments/retry/?$')),
    _Rule('GET', RegExp('^/api/orders/$_order/?\$')),
    _Rule('GET', RegExp('^/api/payments/order/$_order/status/?\$')),
    _Rule('GET', RegExp('^/api/payments/$_order/status/?\$')),
  ];

  /// Whether an express token may be attached to this request.
  static bool isAllowedRequest(String method, String path) {
    String p = path;
    final Uri? uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) p = uri.path;
    p = p.split('?').first;
    if (!p.startsWith('/')) p = '/$p';
    // Accept both '/api/x' (app convention) and '/api/v1/x'.
    p = p.replaceFirst(RegExp(r'^/api/v1(?=/)'), '/api');
    final String verb = method.toUpperCase();
    return _rules.any((_Rule r) => r.method == verb && r.path.hasMatch(p));
  }
}

class _Rule {
  const _Rule(this.method, this.path);
  final String method;
  final RegExp path;
}
