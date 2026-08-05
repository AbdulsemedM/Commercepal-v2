import 'package:commercepal/core/utils/json_utils.dart';

class FeaturedValue {
  final String name;
  final String value;

  FeaturedValue({
    required this.name,
    required this.value,
  });

  factory FeaturedValue.fromJson(Map<String, dynamic> json) {
    return FeaturedValue(
      name: JsonUtils.asString(json['name']),
      value: JsonUtils.asString(json['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
