import 'package:commercepal/core/utils/json_utils.dart';

import 'pricing.dart';
import 'configurator.dart';

class Variant {
  final String configId;
  final int quantity;
  final int salesCount;
  final Pricing? pricing;
  final List<Configurator> configurators;

  Variant({
    required this.configId,
    required this.quantity,
    required this.salesCount,
    this.pricing,
    required this.configurators,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? pricingMap = JsonUtils.asMap(json['pricing']);
    final List<dynamic>? configuratorsList =
        JsonUtils.asList(json['configurators']);
    return Variant(
      configId: JsonUtils.asString(json['configId']),
      quantity: JsonUtils.asIntOr(json['quantity'], 0),
      salesCount: JsonUtils.asIntOr(json['salesCount'], 0),
      pricing: pricingMap != null ? Pricing.fromJson(pricingMap) : null,
      configurators: configuratorsList
              ?.whereType<Map>()
              .map(
                (Map item) => Configurator.fromJson(
                  JsonUtils.asMap(item) ?? const <String, dynamic>{},
                ),
              )
              .toList() ??
          const <Configurator>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'configId': configId,
      'quantity': quantity,
      'salesCount': salesCount,
      'pricing': pricing?.toJson(),
      'configurators': configurators.map((c) => c.toJson()).toList(),
    };
  }
}
