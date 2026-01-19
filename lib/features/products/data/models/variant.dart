import 'pricing.dart';
import 'configurator.dart';

class Variant {
  final String configId;
  final int quantity;
  final int salesCount;
  final Pricing pricing;
  final List<Configurator> configurators;

  Variant({
    required this.configId,
    required this.quantity,
    required this.salesCount,
    required this.pricing,
    required this.configurators,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      configId: json['configId'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      salesCount: json['salesCount'] as int? ?? 0,
      pricing: Pricing.fromJson(
        json['pricing'] as Map<String, dynamic>,
      ),
      configurators: (json['configurators'] as List<dynamic>?)
              ?.map((item) => Configurator.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'configId': configId,
      'quantity': quantity,
      'salesCount': salesCount,
      'pricing': pricing.toJson(),
      'configurators': configurators.map((c) => c.toJson()).toList(),
    };
  }
}
