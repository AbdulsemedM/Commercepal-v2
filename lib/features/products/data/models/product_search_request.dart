class ProductSearchRequest {
  final int page;
  final int size;
  final String? query;
  final String? categoryId;
  final String? provider;
  final String? orderBy;
  final String? brandId;
  final bool? isTmall;
  final bool? useOptimalFrameSize;
  final int? maxVolume;
  final int? minVolume;
  final double? minPrice;
  final double? maxPrice;
  final String? accountType;
  final String? country;
  final String? currency;

  ProductSearchRequest({
    this.page = 0,
    this.size = 60,
    this.query,
    this.categoryId,
    this.provider,
    this.orderBy,
    this.brandId,
    this.isTmall,
    this.useOptimalFrameSize,
    this.maxVolume,
    this.minVolume,
    this.minPrice,
    this.maxPrice,
    this.accountType,
    this.country,
    this.currency,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
    };

    if (query != null && query!.isNotEmpty) {
      params['query'] = query;
    }
    if (categoryId != null && categoryId!.isNotEmpty) {
      params['categoryId'] = categoryId;
    }
    if (provider != null && provider!.isNotEmpty) {
      params['provider'] = provider;
    }
    if (orderBy != null && orderBy!.isNotEmpty) {
      params['orderBy'] = orderBy;
    }
    if (brandId != null && brandId!.isNotEmpty) {
      params['brandId'] = brandId;
    }
    if (isTmall != null) {
      params['isTmall'] = isTmall;
    }
    if (useOptimalFrameSize != null) {
      params['useOptimalFrameSize'] = useOptimalFrameSize;
    }
    if (maxVolume != null) {
      params['maxVolume'] = maxVolume;
    }
    if (minVolume != null) {
      params['minVolume'] = minVolume;
    }
    if (minPrice != null) {
      params['minPrice'] = minPrice;
    }
    if (maxPrice != null) {
      params['maxPrice'] = maxPrice;
    }
    if (accountType != null && accountType!.isNotEmpty) {
      params['accountType'] = accountType;
    }

    return params;
  }

  Map<String, String> toHeaders() {
    final headers = <String, String>{};

    if (country != null && country!.isNotEmpty) {
      headers['X-Country'] = country!;
    }
    if (currency != null && currency!.isNotEmpty) {
      headers['X-Currency'] = currency!;
    }

    return headers;
  }

  ProductSearchRequest copyWith({
    int? page,
    int? size,
    String? query,
    String? categoryId,
    String? provider,
    String? orderBy,
    String? brandId,
    bool? isTmall,
    bool? useOptimalFrameSize,
    int? maxVolume,
    int? minVolume,
    double? minPrice,
    double? maxPrice,
    String? accountType,
    String? country,
    String? currency,
  }) {
    return ProductSearchRequest(
      page: page ?? this.page,
      size: size ?? this.size,
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      provider: provider ?? this.provider,
      orderBy: orderBy ?? this.orderBy,
      brandId: brandId ?? this.brandId,
      isTmall: isTmall ?? this.isTmall,
      useOptimalFrameSize: useOptimalFrameSize ?? this.useOptimalFrameSize,
      maxVolume: maxVolume ?? this.maxVolume,
      minVolume: minVolume ?? this.minVolume,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      accountType: accountType ?? this.accountType,
      country: country ?? this.country,
      currency: currency ?? this.currency,
    );
  }
}
