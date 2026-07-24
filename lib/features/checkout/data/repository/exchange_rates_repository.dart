import '../data_provider/exchange_rates_data_provider.dart';
import '../models/exchange_rates_response.dart';

class ExchangeRatesRepository {
  ExchangeRatesRepository({ExchangeRatesDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? ExchangeRatesDataProvider();

  final ExchangeRatesDataProvider _dataProvider;
  ExchangeRatesData? _cached;

  Future<ExchangeRatesData> getExchangeRates({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) {
      return _cached!;
    }
    final response = await _dataProvider.getExchangeRates();
    _cached = response.toExchangeRatesData();
    return _cached!;
  }
}
