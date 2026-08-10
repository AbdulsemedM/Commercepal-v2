/// Flat payment method from GET /public/payment-methods.
class PublicPaymentMethod {
  final String providerCode;
  final String displayName;
  final String? description;
  final bool requiresAccount;
  final String? accountLabel;
  final String? accountPlaceholder;
  final String? iconUrl;
  final bool isEnabled;
  final int sortOrder;
  final List<String> supportedCurrencies;
  final List<String> supportedCountries;

  PublicPaymentMethod({
    required this.providerCode,
    required this.displayName,
    this.description,
    this.requiresAccount = false,
    this.accountLabel,
    this.accountPlaceholder,
    this.iconUrl,
    this.isEnabled = true,
    this.sortOrder = 0,
    this.supportedCurrencies = const <String>[],
    this.supportedCountries = const <String>[],
  });

  factory PublicPaymentMethod.fromJson(Map<String, dynamic> json) {
    return PublicPaymentMethod(
      providerCode: json['providerCode'] as String? ??
          json['code'] as String? ??
          '',
      displayName: json['displayName'] as String? ?? '',
      description: json['description'] as String?,
      requiresAccount: json['requiresAccount'] as bool? ?? false,
      accountLabel: json['accountLabel'] as String?,
      accountPlaceholder: json['accountPlaceholder'] as String?,
      iconUrl: json['iconUrl'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      supportedCurrencies: (json['supportedCurrencies'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      supportedCountries: (json['supportedCountries'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }
}
