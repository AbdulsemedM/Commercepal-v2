import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:commercepal/core/auth/express_checkout.dart';
import 'package:commercepal/core/constants/country_currency_constants.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/features/addresses/data/models/add_address_request.dart';
import 'package:commercepal/features/profile/data/models/profile_data.dart';
import 'package:commercepal/features/profile/data/repository/profile_repository.dart';
import 'package:commercepal/services/auth_service.dart';

/// Why the delivery address could not be filled in automatically.
enum AutoAddressFailure {
  /// Location services are off on the phone.
  serviceOff,

  /// The shopper declined location access.
  permissionDenied,

  /// No position within the time limit.
  noPosition,

  /// No name/phone number to put on the delivery label.
  noContact,
}

class AutoAddressResult {
  const AutoAddressResult.success(this.request) : failure = null;
  const AutoAddressResult.failed(this.failure) : request = null;

  final AddAddressRequest? request;
  final AutoAddressFailure? failure;
}

/// Builds a delivery address from the phone's location, so checkout does not
/// need the address form. The receiver is the shopper (profile, or the name and
/// number given for phone checkout). The exact GPS pin goes with the address and
/// a map link goes in the landmark, so the courier can find the door even when
/// the street name is unknown.
class LocationAddressService {
  LocationAddressService({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository;

  ProfileRepository? _profileRepository;

  static const Set<String> _supportedCountries = <String>{'ET', 'KE', 'AE', 'SO'};

  Future<AutoAddressResult> buildFromCurrentLocation() async {
    final ({String name, String phone})? contact = await _contact();
    if (contact == null) {
      return const AutoAddressResult.failed(AutoAddressFailure.noContact);
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return const AutoAddressResult.failed(AutoAddressFailure.serviceOff);
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const AutoAddressResult.failed(AutoAddressFailure.permissionDenied);
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (e) {
      AppLogger.w('Current position unavailable: $e');
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {
        position = null;
      }
    }
    if (position == null) {
      return const AutoAddressResult.failed(AutoAddressFailure.noPosition);
    }

    Placemark? place;
    try {
      final List<Placemark> places =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      place = places.isEmpty ? null : places.first;
    } catch (e) {
      // Street names are a bonus; the GPS pin alone is enough for delivery.
      AppLogger.w('Reverse geocoding failed: $e');
    }

    final String lat = position.latitude.toStringAsFixed(6);
    final String lng = position.longitude.toStringAsFixed(6);
    final String iso = (place?.isoCountryCode ?? '').toUpperCase();
    final String country = _supportedCountries.contains(iso)
        ? iso
        : CountryCurrencyConstants.defaultCountryCode;

    return AutoAddressResult.success(
      AddAddressRequest(
        receiverName: contact.name,
        phoneNumber: formatPhone(contact.phone, country),
        countryCode: country,
        state: _clip(place?.administrativeArea, 120),
        city: _clip(_firstNonEmpty(<String?>[place?.locality, place?.subAdministrativeArea]), 120),
        district: _clip(place?.subLocality, 120),
        street: _clip(
          _firstNonEmpty(<String?>[place?.thoroughfare, place?.street, place?.name]) ??
              'Pinned location',
          255,
        ),
        houseNumber: _clip(place?.subThoroughfare, 60),
        landmark: 'Map: https://maps.google.com/?q=$lat,$lng',
        latitude: lat,
        longitude: lng,
        addressSource: 'MAP_PIN',
        isDefault: true,
      ),
    );
  }

  Future<({String name, String phone})?> _contact() async {
    final ExpressCheckout express = ExpressCheckout.instance;
    await express.ensureLoaded();
    if (!AuthService().isLoggedIn && express.isActive) {
      final String phone = (express.phoneNumber ?? '').trim();
      if (phone.isEmpty) return null;
      final String name = (express.firstName ?? '').trim();
      return (name: name.isEmpty ? 'Customer' : name, phone: phone);
    }
    try {
      final ProfileRepository repo = _profileRepository ??= ProfileRepository();
      ProfileData? profile = (await repo.getCachedProfile())?.profile;
      profile ??= (await repo.getProfile()).data;
      final String phone = profile.phoneNumber.trim();
      if (phone.isEmpty) return null;
      final String name = '${profile.firstName} ${profile.lastName}'.trim();
      return (name: name.isEmpty ? 'Customer' : name, phone: phone);
    } catch (e) {
      AppLogger.w('Profile unavailable for automatic address: $e');
      return null;
    }
  }

  /// Same rule as the address form: Ethiopian numbers as +251XXXXXXXXX.
  static String formatPhone(String phoneNumber, String countryCode) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (countryCode == 'ET') {
      if (cleaned.startsWith('+251')) {
        cleaned = cleaned.substring(4);
      } else if (cleaned.startsWith('251')) {
        cleaned = cleaned.substring(3);
      } else if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      cleaned = cleaned.replaceAll('+', '');
      if (cleaned.length == 9) return '+251$cleaned';
    }
    return cleaned.replaceAll('+', '');
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final String? v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  static String _clip(String? value, int max) {
    final String v = (value ?? '').trim();
    return v.length <= max ? v : v.substring(0, max);
  }
}
