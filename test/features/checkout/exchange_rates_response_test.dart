import 'package:commercepal/features/checkout/data/models/exchange_rates_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExchangeRatesResponse', () {
    test('parses foreign-exchange API payload', () {
      final response = ExchangeRatesResponse.fromJson(<String, dynamic>{
        'status': 200,
        'message': 'Success',
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'baseCurrency': 'USD',
            'targetCurrency': 'ETB',
            'rate': 200.0,
          },
          <String, dynamic>{
            'id': 4,
            'baseCurrency': 'USD',
            'targetCurrency': 'AED',
            'rate': 3.6725,
          },
        ],
      });

      expect(response.status, 200);
      expect(response.data, hasLength(2));
      expect(response.data.first.targetCurrency, 'ETB');
    });

    test('toExchangeRatesData builds USD-base map', () {
      final response = ExchangeRatesResponse.fromJson(<String, dynamic>{
        'status': 200,
        'message': 'Success',
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'baseCurrency': 'USD',
            'targetCurrency': 'ETB',
            'rate': 200.0,
          },
          <String, dynamic>{
            'id': 3,
            'baseCurrency': 'USD',
            'targetCurrency': 'KES',
            'rate': 130.0,
          },
        ],
      });

      final rates = response.toExchangeRatesData();
      expect(rates.usdToEtb, 200.0);
      expect(rates.rateFor('KES'), 130.0);
    });
  });

  group('ExchangeRatesData', () {
    test('toUsd converts any supported target currency', () {
      const data = ExchangeRatesData(usdToTarget: <String, double>{
        'ETB': 200,
        'KES': 130,
        'SOS': 570,
        'AED': 3.67,
      });

      expect(data.toUsd(1040, 'ETB'), closeTo(5.2, 0.0001));
      expect(data.toUsd(1300, 'KES'), closeTo(10, 0.0001));
      expect(data.toUsd(570, 'SOS'), closeTo(1, 0.0001));
      expect(data.toUsd(25, 'USD'), 25);
    });

    test('toUsd returns 0 when rate is missing', () {
      const data = ExchangeRatesData(usdToTarget: <String, double>{});

      expect(data.toUsd(1040, 'ETB'), 0);
      expect(data.hasRateFor('ETB'), isFalse);
    });
  });
}
