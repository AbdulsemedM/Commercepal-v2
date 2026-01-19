class FeaturedValue {
  final String name;
  final String value;

  FeaturedValue({
    required this.name,
    required this.value,
  });

  factory FeaturedValue.fromJson(Map<String, dynamic> json) {
    return FeaturedValue(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
