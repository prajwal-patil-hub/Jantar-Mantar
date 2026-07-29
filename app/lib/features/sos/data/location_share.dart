import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// One-shot location fix for the explicit "share my location" action (E7).
///
/// This is the ONLY place in the app that touches GPS, and the constraints
/// are the point (SECURITY.md, CONTEXT.md):
///   * requested per use, never on launch and never in the background —
///     `getCurrentPosition` only, no position stream, no `whileInUse`
///     upgrade to `always`;
///   * the fix goes to the OS share sheet and nowhere else. It is never
///     written to Drift, never queued in the outbox, and never sent to
///     Supabase — "don't store precise user location server-side" is not
///     satisfied by "we only keep it briefly";
///   * a denial is a normal outcome, not an error state: the caller falls
///     back to sharing nothing.
enum LocationFailure { serviceOff, denied, deniedForever, timeout }

sealed class LocationResult {
  const LocationResult();
}

class LocationFix extends LocationResult {
  const LocationFix({
    required this.lat,
    required this.lng,
    required this.accuracyMeters,
    required this.at,
  });

  final double lat;
  final double lng;
  final double accuracyMeters;
  final DateTime at;

  /// A link any map app can open, on OpenStreetMap rather than a vendor's
  /// servers — the recipient should not have to tell Google where the sender
  /// is in order to read it (ADR-7).
  String get osmUrl =>
      'https://www.openstreetmap.org/?mlat=${lat.toStringAsFixed(5)}'
      '&mlon=${lng.toStringAsFixed(5)}#map=17/'
      '${lat.toStringAsFixed(5)}/${lng.toStringAsFixed(5)}';
}

class LocationDenied extends LocationResult {
  const LocationDenied(this.reason);
  final LocationFailure reason;
}

abstract class LocationService {
  Future<LocationResult> currentFix();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationResult> currentFix() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationDenied(LocationFailure.serviceOff);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationDenied(LocationFailure.deniedForever);
    }
    if (permission == LocationPermission.denied) {
      return const LocationDenied(LocationFailure.denied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          // Someone who needs this is not going to wait; a rough fix beats
          // a spinner.
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocationFix(
        lat: position.latitude,
        lng: position.longitude,
        accuracyMeters: position.accuracy,
        at: position.timestamp,
      );
    } on Object {
      return const LocationDenied(LocationFailure.timeout);
    }
  }
}

/// Test seam — widget tests never touch a platform channel.
final locationServiceProvider = Provider<LocationService>(
  (ref) => const GeolocatorLocationService(),
);
