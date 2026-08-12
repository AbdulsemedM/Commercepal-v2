import 'package:commercepal/features/checkout/data/models/payment_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('checkoutDisplaySortRank', () {
    test('orders QPay before eBirr before CBE before others', () {
      expect(PaymentConstants.checkoutDisplaySortRank('QPAY'), 0);
      expect(PaymentConstants.checkoutDisplaySortRank('E_BIRR'), 1);
      expect(PaymentConstants.checkoutDisplaySortRank('EBIRR_COOPAY'), 1);
      expect(PaymentConstants.checkoutDisplaySortRank('EBIRR_KAFFI'), 1);
      expect(PaymentConstants.checkoutDisplaySortRank('CBE_BIRR'), 2);
      expect(PaymentConstants.checkoutDisplaySortRank('TELEBIRR'), 3);
      expect(PaymentConstants.checkoutDisplaySortRank('PAYPAL'), 3);
    });

    test('does not classify Telebirr as eBirr', () {
      expect(PaymentConstants.isEbirr('TELEBIRR'), isFalse);
      expect(PaymentConstants.isEbirr('TELE_BIRR'), isFalse);
    });
  });
}
