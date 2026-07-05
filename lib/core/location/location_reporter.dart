import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../network/cargo_api.dart';

/// Periodically reports the driver's current GPS position to the backend
/// for one active delivery, while explicitly toggled on.
///
/// This is not a background service: the timer only runs while the
/// owning widget is alive and [start] has been called. Navigating away
/// (and calling [stop]) or closing the app stops sharing — there is no
/// true background execution.
class LocationReporter {
  final CargoApi _cargoApi;
  Timer? _timer;

  LocationReporter({CargoApi? cargoApi}) : _cargoApi = cargoApi ?? CargoApi();

  bool get isActive => _timer != null;

  Future<bool> start(
    String token,
    String listingId, {
    Duration interval = const Duration(seconds: 8),
  }) async {
    if (!await _ensurePermission()) return false;

    await _tick(token, listingId);
    _timer = Timer.periodic(interval, (_) => _tick(token, listingId));
    return true;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _tick(String token, String listingId) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await _cargoApi.updateLocation(
        token,
        listingId,
        position.latitude,
        position.longitude,
      );
    } catch (_) {
      // Non-fatal — skip this tick rather than killing the sharing loop.
    }
  }
}
