class ForeignExchangeRate {
  final int id;
  final String baseCurrency;
  final String targetCurrency;
  final double rate;

  const ForeignExchangeRate({
    required this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
  });

  factory ForeignExchangeRate.fromJson(Map<String, dynamic> json) {
    return ForeignExchangeRate(
      id: json['id'] as int? ?? 0,
      baseCurrency: (json['baseCurrency'] as String? ?? 'USD').toUpperCase(),
      targetCurrency: (json['targetCurrency'] as String? ?? '').toUpperCase(),
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// USD-base rates keyed by target currency (e.g. ETB -> 200 means 1 USD = 200 ETB).
class ExchangeRatesData {
  final Map<String, double> usdToTarget;

  const ExchangeRatesData({required this.usdToTarget});

  factory ExchangeRatesData.fromRates(List<ForeignExchangeRate> rates) {
    final Map<String, double> map = <String, double>{};
    for (final ForeignExchangeRate rate in rates) {
      if (rate.baseCurrency != 'USD') continue;
      if (rate.targetCurrency.isEmpty || rate.rate <= 0) continue;
      map[rate.targetCurrency] = rate.rate;
    }
    return ExchangeRatesData(usdToTarget: map);
  }

  double? rateFor(String targetCurrency) {
    if (targetCurrency.isEmpty) return null;
    return usdToTarget[targetCurrency.toUpperCase()];
  }

  bool hasRateFor(String targetCurrency) {
    final double? rate = rateFor(targetCurrency);
    return rate != null && rate > 0;
  }

  /// Converts an amount in [targetCurrency] to USD (1 USD = rate target units).
  double toUsd(double amount, String targetCurrency) {
    final String code = targetCurrency.toUpperCase();
    if (code == 'USD') return amount;
    final double? rate = rateFor(code);
    if (rate == null || rate <= 0) return 0;
    return amount / rate;
  }

  /// Backward-compatible ETB conversion helper.
  double etbToUsd(double etbAmount) => toUsd(etbAmount, 'ETB');

  double get usdToEtb => usdToTarget['ETB'] ?? 0;

  double get usdToAed => usdToTarget['AED'] ?? 0;
}

class ExchangeRatesResponse {
  final int status;
  final String message;
  final List<ForeignExchangeRate> data;

  ExchangeRatesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ExchangeRatesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['data'] as List<dynamic>? ?? <dynamic>[];
    return ExchangeRatesResponse(
      status: json['status'] as int? ?? 200,
      message: json['message'] as String? ?? '',
      data: raw
          .whereType<Map<String, dynamic>>()
          .map(ForeignExchangeRate.fromJson)
          .toList(),
    );
  }

  ExchangeRatesData toExchangeRatesData() =>
      ExchangeRatesData.fromRates(data);
}
