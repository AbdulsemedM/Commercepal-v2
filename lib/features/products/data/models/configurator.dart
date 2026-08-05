import 'package:commercepal/core/utils/json_utils.dart';

class Configurator {
  final String propertyId;
  final String valueId;
  final String propertyName;
  final String value;
  final String? imageUrl;
  final String? miniImageUrl;
  final bool isConfigurator;

  Configurator({
    required this.propertyId,
    required this.valueId,
    required this.propertyName,
    required this.value,
    this.imageUrl,
    this.miniImageUrl,
    required this.isConfigurator,
  });

  factory Configurator.fromJson(Map<String, dynamic> json) {
    final String imageUrl = JsonUtils.asString(json['imageUrl']);
    final String miniImageUrl = JsonUtils.asString(json['miniImageUrl']);
    return Configurator(
      propertyId: JsonUtils.asString(json['propertyId']),
      valueId: JsonUtils.asString(json['valueId']),
      propertyName: JsonUtils.asString(json['propertyName']),
      value: JsonUtils.asString(json['value']),
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      miniImageUrl: miniImageUrl.isEmpty ? null : miniImageUrl,
      isConfigurator: JsonUtils.asBool(json['isConfigurator']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'valueId': valueId,
      'propertyName': propertyName,
      'value': value,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (miniImageUrl != null) 'miniImageUrl': miniImageUrl,
      'isConfigurator': isConfigurator,
    };
  }
}
