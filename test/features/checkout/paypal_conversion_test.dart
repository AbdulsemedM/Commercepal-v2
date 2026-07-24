import 'package:commercepal/core/utils/money_formatter.dart';
import 'package:commercepal/features/checkout/data/models/exchange_rates_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PayPal currency to USD conversion', () {
    const rates = ExchangeRatesData(usdToTarget: <String, double>{
      'ETB': 200,
      'KES': 130,
      'SOS': 570,
      'AED': 3.6725,
    });

    test('converts ETB cart total to USD', () {
      const etbTotal = 2080.0;
      final usdAmount = rates.toUsd(etbTotal, 'ETB');

      expect(usdAmount, 10.4);
      expect(MoneyFormatter.format(usdAmount, 'USD'), 'USD 10.40');
      expect(MoneyFormatter.format(etbTotal, 'ETB'), 'ETB 2,080.00');
    });

    test('converts KES cart total to USD', () {
      expect(rates.toUsd(1300, 'KES'), 10);
    });
  });
}
