import 'package:commercepal/core/utils/json_utils.dart';

class PhysicalParameters {
  final double length;
  final double width;
  final double height;
  final double weight;

  PhysicalParameters({
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
  });

  factory PhysicalParameters.fromJson(Map<String, dynamic> json) {
    return PhysicalParameters(
      length: JsonUtils.asDoubleOr(json['length'], 0.0),
      width: JsonUtils.asDoubleOr(json['width'], 0.0),
      height: JsonUtils.asDoubleOr(json['height'], 0.0),
      weight: JsonUtils.asDoubleOr(json['weight'], 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'width': width,
      'height': height,
      'weight': weight,
    };
  }
}
