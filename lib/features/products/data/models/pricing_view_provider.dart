class PricingViewProvider {
  final String providerCurrency;
  final double providerUnitPrice;
  final double unitMarkup;

  PricingViewProvider({
    required this.providerCurrency,
    required this.providerUnitPrice,
    required this.unitMarkup,
  });

  factory PricingViewProvider.fromJson(Map<String, dynamic> json) {
    return PricingViewProvider(
      providerCurrency: json['providerCurrency'] as String? ?? 'USD',
      providerUnitPrice: (json['providerUnitPrice'] as num?)?.toDouble() ?? 0.0,
      unitMarkup: (json['unitMarkup'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerCurrency': providerCurrency,
      'providerUnitPrice': providerUnitPrice,
      'unitMarkup': unitMarkup,
    };
  }
}
