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
      length: (json['length'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
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
