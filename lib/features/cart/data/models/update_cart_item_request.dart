class UpdateCartItemRequest {
  final int quantity;
  final String? replaceConfigId;

  UpdateCartItemRequest({
    required this.quantity,
    this.replaceConfigId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'quantity': quantity,
      'replaceConfigId': replaceConfigId,
    };
  }
}

