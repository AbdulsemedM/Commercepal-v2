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
    return Configurator(
      propertyId: json['propertyId'] as String? ?? '',
      valueId: json['valueId'] as String? ?? '',
      propertyName: json['propertyName'] as String? ?? '',
      value: json['value'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      miniImageUrl: json['miniImageUrl'] as String?,
      isConfigurator: json['isConfigurator'] as bool? ?? false,
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
