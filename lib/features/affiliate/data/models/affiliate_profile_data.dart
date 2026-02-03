class AffiliateProfileData {
  final String referralCode;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String commissionType;
  final num commissionRate;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  AffiliateProfileData({
    required this.referralCode,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.commissionType,
    required this.commissionRate,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AffiliateProfileData.fromJson(Map<String, dynamic> json) =>
      AffiliateProfileData(
        referralCode: json['referralCode'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        commissionType: json['commissionType'] as String? ?? 'PERCENTAGE',
        commissionRate: (json['commissionRate'] as num?) ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'referralCode': referralCode,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'commissionType': commissionType,
        'commissionRate': commissionRate,
        'isActive': isActive,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };
}
