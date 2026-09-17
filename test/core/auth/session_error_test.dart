import 'package:commercepal/core/auth/session_error.dart';
import 'package:commercepal/core/network/interceptors/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isUnauthorizedError', () {
    test('detects DioException 401 and 403', () {
      expect(
        isUnauthorizedError(
          DioException(
            requestOptions: RequestOptions(path: '/api/profile'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/profile'),
              statusCode: 401,
            ),
          ),
        ),
        isTrue,
      );
      expect(
        isUnauthorizedError(
          DioException(
            requestOptions: RequestOptions(path: '/api/profile'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/profile'),
              statusCode: 403,
            ),
          ),
        ),
        isTrue,
      );
    });

    test('ignores unrelated status codes', () {
      expect(
        isUnauthorizedError(
          DioException(
            requestOptions: RequestOptions(path: '/api/products/search'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/products/search'),
              statusCode: 404,
            ),
          ),
        ),
        isFalse,
      );
    });

    test('does not substring-match arbitrary error text', () {
      expect(
        isUnauthorizedError(
          Exception('Product aesg-100500704774401 failed to load'),
        ),
        isFalse,
      );
    });

    test('detects SessionRejected', () {
      expect(isUnauthorizedError(const SessionRejected()), isTrue);
    });

    test('detects explicit session messages in response body', () {
      expect(
        isUnauthorizedError(
          DioException(
            requestOptions: RequestOptions(path: '/api/orders'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/orders'),
              statusCode: 400,
              data: <String, dynamic>{'message': 'Session expired'},
            ),
          ),
        ),
        isTrue,
      );
    });
  });
}
