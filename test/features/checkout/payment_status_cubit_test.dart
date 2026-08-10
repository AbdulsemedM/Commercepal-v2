import 'package:commercepal/features/checkout/bloc/payment_status_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PaymentStatusCubit polls every 5 seconds up to 30 minutes', () {
    expect(PaymentStatusCubit.pollInterval, const Duration(seconds: 5));
    expect(PaymentStatusCubit.maxAttempts, 360);
  });
}
