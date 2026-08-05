import 'package:commercepal/core/utils/json_utils.dart';

import 'pricing_view_provider.dart';

class Pricing {
  final String currency;
  final double currentPrice;
  final double originalPrice;
  final double discountAmount;
  final bool isOnDiscount;
  final double discountPercentage;
  final String formattedDiscountPercentage;
  final String formattedCurrentPrice;
  final String formattedOriginalPrice;
  final String formattedDiscountAmount;
  final PricingViewProvider? pricingViewProvider;

  Pricing({
    required this.currency,
    required this.currentPrice,
    required this.originalPrice,
    required this.discountAmount,
    required this.isOnDiscount,
    required this.discountPercentage,
    required this.formattedDiscountPercentage,
    required this.formattedCurrentPrice,
    required this.formattedOriginalPrice,
    required this.formattedDiscountAmount,
    this.pricingViewProvider,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? providerMap =
        JsonUtils.asMap(json['pricingViewProvider']);
    return Pricing(
      // Left empty on purpose: a missing pricing block must not mislabel prices
      // as USD. Consumers fall back to the shopper's selected currency.
      currency: JsonUtils.asString(json['currency']),
      currentPrice: JsonUtils.asDoubleOr(json['currentPrice'], 0.0),
      originalPrice: JsonUtils.asDoubleOr(json['originalPrice'], 0.0),
      discountAmount: JsonUtils.asDoubleOr(json['discountAmount'], 0.0),
      isOnDiscount: JsonUtils.asBool(json['isOnDiscount']),
      discountPercentage: JsonUtils.asDoubleOr(json['discountPercentage'], 0.0),
      formattedDiscountPercentage:
          JsonUtils.asString(json['formattedDiscountPercentage']),
      formattedCurrentPrice: JsonUtils.asString(json['formattedCurrentPrice']),
      formattedOriginalPrice: JsonUtils.asString(json['formattedOriginalPrice']),
      formattedDiscountAmount: JsonUtils.asString(json['formattedDiscountAmount']),
      pricingViewProvider: providerMap != null
          ? PricingViewProvider.fromJson(providerMap)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'currentPrice': currentPrice,
      'originalPrice': originalPrice,
      'discountAmount': discountAmount,
      'isOnDiscount': isOnDiscount,
      'discountPercentage': discountPercentage,
      'formattedDiscountPercentage': formattedDiscountPercentage,
      'formattedCurrentPrice': formattedCurrentPrice,
      'formattedOriginalPrice': formattedOriginalPrice,
      'formattedDiscountAmount': formattedDiscountAmount,
      if (pricingViewProvider != null)
        'pricingViewProvider': pricingViewProvider!.toJson(),
    };
  }
}
