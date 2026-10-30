// Payloads behind the affiliate dashboard (mirrors commercepal.com/affiliate).

num _num(Object? v) => v is num ? v : num.tryParse('${v ?? ''}') ?? 0;

String? _str(Object? v) {
  final String? s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

/// GET /api/affiliates/commisions/summary
class AffiliateCommissionSummary {
  const AffiliateCommissionSummary({
    required this.totalEarned,
    required this.totalPayout,
    required this.remainingAmount,
  });

  final num totalEarned;
  final num totalPayout;
  final num remainingAmount;

  factory AffiliateCommissionSummary.fromJson(Map<String, dynamic> json) =>
      AffiliateCommissionSummary(
        totalEarned: _num(json['totalEarned']),
        totalPayout: _num(json['totalPayout']),
        remainingAmount: _num(json['remainingAmount']),
      );
}

/// GET /api/affiliate/withdrawals/stats
class AffiliateWithdrawalStats {
  const AffiliateWithdrawalStats({
    required this.pendingAmount,
    required this.approvedAmount,
    required this.paidAmount,
  });

  final num pendingAmount;
  final num approvedAmount;
  final num paidAmount;

  factory AffiliateWithdrawalStats.fromJson(Map<String, dynamic> json) =>
      AffiliateWithdrawalStats(
        pendingAmount: _num(json['pendingAmount']),
        approvedAmount: _num(json['approvedAmount']),
        paidAmount: _num(json['paidAmount']),
      );
}

/// GET /api/affiliates/commisions — only the type is needed (order count
/// fallback when order-earnings is empty).
class AffiliateCommission {
  const AffiliateCommission({required this.commissionType});

  final String? commissionType;

  factory AffiliateCommission.fromJson(Map<String, dynamic> json) =>
      AffiliateCommission(commissionType: _str(json['commissionType']));
}

/// GET /api/affiliates/commisions/order-earnings
class AffiliateOrderEarning {
  const AffiliateOrderEarning({
    required this.orderRef,
    required this.customerName,
    required this.orderAmount,
    required this.commissionAmount,
    required this.remainingUnpaidAmount,
    required this.currency,
    this.orderStatus,
    this.paymentStatus,
    this.earningStatus,
    this.orderedAt,
    this.earnedAt,
  });

  final String orderRef;
  final String customerName;
  final num orderAmount;
  final num commissionAmount;
  final num remainingUnpaidAmount;
  final String currency;
  final String? orderStatus;
  final String? paymentStatus;
  final String? earningStatus;
  final String? orderedAt;
  final String? earnedAt;

  factory AffiliateOrderEarning.fromJson(Map<String, dynamic> json) =>
      AffiliateOrderEarning(
        orderRef: _str(json['orderRef']) ?? '',
        customerName: _str(json['customerName']) ?? '',
        orderAmount: _num(json['orderAmount']),
        commissionAmount: _num(json['commissionAmount']),
        remainingUnpaidAmount: _num(json['remainingUnpaidAmount']),
        currency: _str(json['currency']) ?? 'ETB',
        orderStatus: _str(json['orderStatus']),
        paymentStatus: _str(json['paymentStatus']),
        earningStatus: _str(json['earningStatus']),
        orderedAt: _str(json['orderedAt']),
        earnedAt: _str(json['earnedAt']),
      );
}

/// GET /api/affiliate/withdrawals/my-withdrawals
class AffiliateWithdrawal {
  const AffiliateWithdrawal({
    required this.id,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.accountNumber,
    this.bankName,
    this.requestedAt,
    this.paidAt,
    this.rejectionReason,
    this.payoutReference,
    this.adminNotes,
  });

  final String id;
  final num amount;
  final String status;
  final String? paymentMethod;
  final String? accountNumber;
  final String? bankName;
  final String? requestedAt;
  final String? paidAt;
  final String? rejectionReason;
  final String? payoutReference;
  final String? adminNotes;

  /// `****1234` — never show the full payout account.
  String get maskedAccount {
    final String account = accountNumber ?? '';
    return account.length > 4
        ? '****${account.substring(account.length - 4)}'
        : account;
  }

  factory AffiliateWithdrawal.fromJson(Map<String, dynamic> json) =>
      AffiliateWithdrawal(
        id: _str(json['id']) ?? '',
        amount: _num(json['amount']),
        status: _str(json['status'])?.toUpperCase() ?? 'PENDING',
        paymentMethod: _str(json['paymentMethod']),
        accountNumber: _str(json['accountNumber']),
        bankName: _str(json['bankName']),
        requestedAt: _str(json['requestedAt']),
        paidAt: _str(json['paidAt']),
        rejectionReason: _str(json['rejectionReason']),
        payoutReference: _str(json['payoutReference']),
        adminNotes: _str(json['adminNotes']),
      );
}

/// How the affiliate plans to promote (web join form).
enum AffiliatePromotionMethod {
  socialMedia('SOCIAL_MEDIA', 'affiliate.promoSocialMedia'),
  whatsapp('WHATSAPP', 'affiliate.promoWhatsapp'),
  friendsFamily('FRIENDS_FAMILY', 'affiliate.promoFriendsFamily'),
  other('OTHER', 'affiliate.promoOther');

  const AffiliatePromotionMethod(this.apiValue, this.labelKey);

  final String apiValue;
  final String labelKey;
}

/// Payout destinations offered on the web dashboard.
enum AffiliatePayoutMethod {
  telebirr('affiliate.payoutTelebirr'),
  cbe('affiliate.payoutCbe'),
  sahayPay('affiliate.payoutSahayPay');

  const AffiliatePayoutMethod(this.labelKey);

  final String labelKey;
}
