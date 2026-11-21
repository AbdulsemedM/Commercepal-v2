import 'package:commercepal/features/addresses/data/location_address_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationAddressService.formatPhone', () {
    test('Ethiopian numbers become +251XXXXXXXXX', () {
      expect(LocationAddressService.formatPhone('0911679409', 'ET'), '+251911679409');
      expect(LocationAddressService.formatPhone('+251911679409', 'ET'), '+251911679409');
      expect(LocationAddressService.formatPhone('251 911 679 409', 'ET'), '+251911679409');
      expect(LocationAddressService.formatPhone('911679409', 'ET'), '+251911679409');
    });

    test('other countries keep digits only', () {
      expect(LocationAddressService.formatPhone('+254 712 345 678', 'KE'), '254712345678');
    });
  });
}
