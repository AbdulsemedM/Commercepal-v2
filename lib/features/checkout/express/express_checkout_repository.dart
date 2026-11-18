import 'package:commercepal/core/auth/express_checkout.dart';
import 'package:commercepal/services/api_service.dart';

/// Starts phone checkout without a login code (see [ExpressCheckout]).
class ExpressCheckoutRepository {
  ExpressCheckoutRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  static const String _endpoint = '/api/express-checkout/session';

  Future<void> start({
    required String firstName,
    required String phoneNumber,
    required String countryCode,
    String? email,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      _endpoint,
      data: <String, dynamic>{
        'firstName': firstName.trim(),
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      },
    );
    final Object? data = response.data?['data'];
    if (data is! Map<String, dynamic> || data['accessToken'] is! String) {
      throw StateError('Could not start checkout. Please try again.');
    }
    await ExpressCheckout.instance.start(
      token: data['accessToken'] as String,
      expiresInSeconds: (data['expiresIn'] as num?)?.toInt() ?? 3600,
      phoneNumber: (data['phoneNumber'] as String?) ?? phoneNumber,
      firstName: firstName.trim(),
    );
  }
}
