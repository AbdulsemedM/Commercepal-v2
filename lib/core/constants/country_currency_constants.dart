class CountryInfo {
  final String code;
  final String name;
  final String flagEmoji;

  const CountryInfo({
    required this.code,
    required this.name,
    required this.flagEmoji,
  });
}

class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class CountryCurrencyConstants {
  // Default values (Ethiopia / ETB)
  static const String defaultCountryCode = 'ET';
  static const String defaultCurrencyCode = 'ETB';

  // Supported countries (US removed; Ethiopia is default)
  static const List<CountryInfo> supportedCountries = [
    CountryInfo(
      code: 'ET',
      name: 'Ethiopia',
      flagEmoji: '🇪🇹',
    ),
    CountryInfo(
      code: 'SO',
      name: 'Somalia',
      flagEmoji: '🇸🇴',
    ),
    CountryInfo(
      code: 'KE',
      name: 'Kenya',
      flagEmoji: '🇰🇪',
    ),
    CountryInfo(
      code: 'AE',
      name: 'United Arab Emirates',
      flagEmoji: '🇦🇪',
    ),
  ];

  // Supported currencies (ETB default; USD kept)
  static const List<CurrencyInfo> supportedCurrencies = [
    CurrencyInfo(
      code: 'ETB',
      name: 'Ethiopian Birr',
      symbol: 'Br',
    ),
    CurrencyInfo(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
    ),
    CurrencyInfo(
      code: 'KES',
      name: 'Kenyan Shilling',
      symbol: 'KSh',
    ),
    CurrencyInfo(
      code: 'SOS',
      name: 'Somali Shilling',
      symbol: 'Sh',
    ),
    CurrencyInfo(
      code: 'AED',
      name: 'UAE Dirham',
      symbol: 'د.إ',
    ),
  ];

  // Helper methods
  static CountryInfo? getCountryByCode(String code) {
    try {
      return supportedCountries.firstWhere((country) => country.code == code);
    } catch (e) {
      return null;
    }
  }

  static CurrencyInfo? getCurrencyByCode(String code) {
    try {
      return supportedCurrencies.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  static String getCountryName(String code) {
    return getCountryByCode(code)?.name ?? code;
  }

  static String getCurrencyName(String code) {
    return getCurrencyByCode(code)?.name ?? code;
  }

  static String getCurrencySymbol(String code) {
    return getCurrencyByCode(code)?.symbol ?? code;
  }
}
