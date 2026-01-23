class UpdateCartItemRequest {
  final int quantity;
  final String? replaceConfigId;

  UpdateCartItemRequest({
    required this.quantity,
    this.replaceConfigId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'quantity': quantity,
    };
    if (replaceConfigId != null) {
      json['replaceConfigId'] = replaceConfigId;
    }
    return json;
  }
}

