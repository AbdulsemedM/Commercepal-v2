import 'package:commercepal/features/checkout/data/models/payment_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('checkoutDisplaySortRank', () {
    test('orders QPay, eBirr, CBE, Amole, COD, Telebirr, then others', () {
      expect(PaymentConstants.checkoutDisplaySortRank('QPAY'), 0);
      expect(PaymentConstants.checkoutDisplaySortRank('E_BIRR'), 1);
      expect(PaymentConstants.checkoutDisplaySortRank('EBIRR_COOPAY'), 1);
      expect(PaymentConstants.checkoutDisplaySortRank('EBIRR_KAFFI'), 1);
      expect(PaymentConstants.checkoutDisplaySortRank('CBE_BIRR'), 2);
      expect(PaymentConstants.checkoutDisplaySortRank('AMOLE'), 3);
      expect(PaymentConstants.checkoutDisplaySortRank('COD'), 4);
      expect(PaymentConstants.checkoutDisplaySortRank('CASH_ON_DELIVERY'), 4);
      expect(PaymentConstants.checkoutDisplaySortRank('TELEBIRR'), 5);
      expect(PaymentConstants.checkoutDisplaySortRank('TELE_BIRR'), 5);
      expect(PaymentConstants.checkoutDisplaySortRank('PAYPAL'), 6);
      expect(PaymentConstants.checkoutDisplaySortRank('EDAHAB'), 6);
    });

    test('does not classify Telebirr or Edahab as eBirr', () {
      expect(PaymentConstants.isEbirr('TELEBIRR'), isFalse);
      expect(PaymentConstants.isEbirr('TELE_BIRR'), isFalse);
      expect(PaymentConstants.isEbirr('EDAHAB'), isFalse);
    });
  });
}
