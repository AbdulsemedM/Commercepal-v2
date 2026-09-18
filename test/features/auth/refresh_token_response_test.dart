import 'package:commercepal/features/auth/refresh/data/models/refresh_token_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RefreshTokenResponse.fromJson', () {
    test('parses nested API envelope fields', () {
      const envelope = <String, dynamic>{
        'status': 200,
        'message': 'Success',
        'data': <String, dynamic>{
          'accessToken': 'access-abc',
          'refreshToken': 'refresh-xyz',
          'tokenType': 'Bearer',
          'expiresIn': 3600,
        },
      };

      final data = envelope['data'] as Map<String, dynamic>;
      final response = RefreshTokenResponse.fromJson(data);

      expect(response.accessToken, 'access-abc');
      expect(response.refreshToken, 'refresh-xyz');
      expect(response.tokenType, 'Bearer');
      expect(response.expiresIn, 3600);
    });

    test('accepts token alias for accessToken', () {
      final response = RefreshTokenResponse.fromJson(<String, dynamic>{
        'token': 'access-from-token-key',
        'refreshToken': 'refresh-xyz',
      });

      expect(response.accessToken, 'access-from-token-key');
      expect(response.refreshToken, 'refresh-xyz');
      expect(response.tokenType, 'Bearer');
      expect(response.expiresIn, 3600);
    });

    test('throws when accessToken is missing', () {
      expect(
        () => RefreshTokenResponse.fromJson(<String, dynamic>{
          'refreshToken': 'refresh-xyz',
        }),
        throwsFormatException,
      );
    });
  });
}
