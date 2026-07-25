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
    return Pricing(
      // Left empty on purpose: a missing pricing block must not mislabel prices
      // as USD. Consumers fall back to the shopper's selected currency.
      currency: json['currency'] as String? ?? '',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      isOnDiscount: json['isOnDiscount'] as bool? ?? false,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      formattedDiscountPercentage: json['formattedDiscountPercentage'] as String? ?? '',
      formattedCurrentPrice: json['formattedCurrentPrice'] as String? ?? '',
      formattedOriginalPrice: json['formattedOriginalPrice'] as String? ?? '',
      formattedDiscountAmount: json['formattedDiscountAmount'] as String? ?? '',
      pricingViewProvider: json['pricingViewProvider'] != null
          ? PricingViewProvider.fromJson(
              json['pricingViewProvider'] as Map<String, dynamic>,
            )
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
