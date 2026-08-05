import 'package:commercepal/core/utils/json_utils.dart';

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
      providerCurrency: JsonUtils.asString(json['providerCurrency'], 'USD'),
      providerUnitPrice: JsonUtils.asDoubleOr(json['providerUnitPrice'], 0.0),
      unitMarkup: JsonUtils.asDoubleOr(json['unitMarkup'], 0.0),
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
