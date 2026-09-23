import 'package:commercepal/features/auth/reset_password/data/models/reset_password_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResetPasswordRequest', () {
    test('serializes API field names', () {
      final request = ResetPasswordRequest(
        target: 'user@example.com',
        verificationToken: '716810',
        newPassword: '12345678',
        confirmPassword: '12345678',
        channel: 'MOBILE_APP_IOS',
      );

      expect(request.toJson(), <String, dynamic>{
        'target': 'user@example.com',
        'verificationToken': '716810',
        'newPassword': '12345678',
        'confirmPassword': '12345678',
        'channel': 'MOBILE_APP_IOS',
      });
    });
  });
}
