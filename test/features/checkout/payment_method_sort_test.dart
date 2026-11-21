import 'package:commercepal/features/checkout/data/models/payment_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('checkoutDisplaySortRank', () {
    test('orders All Banks (QPay), Telebirr, eBirr, CBE, Amole, COD, then others', () {
      expect(PaymentConstants.checkoutDisplaySortRank('QPAY'), 0);
      expect(PaymentConstants.checkoutDisplaySortRank('TELEBIRR'), 1);
      expect(PaymentConstants.checkoutDisplaySortRank('TELE_BIRR'), 1);
      expect(PaymentConstants.checkoutDisplaySortRank('E_BIRR'), 2);
      expect(PaymentConstants.checkoutDisplaySortRank('EBIRR_COOPAY'), 2);
      expect(PaymentConstants.checkoutDisplaySortRank('EBIRR_KAFFI'), 2);
      expect(PaymentConstants.checkoutDisplaySortRank('CBE_BIRR'), 3);
      expect(PaymentConstants.checkoutDisplaySortRank('AMOLE'), 4);
      expect(PaymentConstants.checkoutDisplaySortRank('COD'), 5);
      expect(PaymentConstants.checkoutDisplaySortRank('CASH_ON_DELIVERY'), 5);
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
