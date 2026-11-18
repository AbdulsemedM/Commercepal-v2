import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/services/api_service.dart';

/// First launch only: pick the shopping market from the shopper's location,
/// like the website does (`/api/geo`). Today this switches Kenyan shoppers to
/// Kenya / KES so they see shilling prices and M-Pesa; everyone else keeps the
/// Ethiopia / ETB default. A choice the user made in settings is never changed.
class MarketAutoDetect {
  MarketAutoDetect._();

  static const String _selectedCountryKey = 'selected_country_code';
  static const String _doneKey = 'market_auto_detect_done';

  static const Map<String, String> _currencyByCountry = <String, String>{
    'KE': 'KES',
  };

  static Future<void> runOnce({ApiService? api}) async {
    final Storage storage = Storage();
    try {
      if (await storage.readData(_doneKey) == 'true') return;
      final String? chosen = await storage.readData(_selectedCountryKey);
      if (chosen != null && chosen.isNotEmpty) {
        await storage.writeData(key: _doneKey, value: 'true');
        return;
      }

      final response = await (api ?? ApiService()).get<Map<String, dynamic>>(
        '/api/geo',
      );
      final Object? code = response.data?['countryCode'];
      final String? currency =
          code is String ? _currencyByCountry[code.toUpperCase()] : null;
      if (currency != null) {
        await storage.saveSelectedCountry((code as String).toUpperCase());
        await storage.saveSelectedCurrency(currency);
        AppLogger.i('Market auto-detected: $code / $currency');
      }
      await storage.writeData(key: _doneKey, value: 'true');
    } catch (e) {
      // Offline or lookup failed: try again next launch.
      AppLogger.w('Market auto-detect skipped: $e');
    }
  }
}
