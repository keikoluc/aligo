import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/cargo_categories.dart';
import '../../core/network/cargo_api.dart';
import '../../core/network/realtime_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cargo_listing_model.dart';
import '../../widgets/aligo_map_view.dart';
import '../../widgets/mock_map_background.dart';

/// Shipper flow: shows a matched delivery's pickup/dropoff and, while the
/// driver has location sharing on, displays their live position — pushed
/// instantly over a socket, with a slow poll as a fallback in case the
/// socket connection drops.
class TrackDeliveryScreen extends StatefulWidget {
  final String token;
  final CargoListingModel listing;

  const TrackDeliveryScreen({
    super.key,
    required this.token,
    required this.listing,
  });

  @override
  State<TrackDeliveryScreen> createState() => _TrackDeliveryScreenState();
}

class _TrackDeliveryScreenState extends State<TrackDeliveryScreen> {
  final _cargoApi = CargoApi();
  final _realtime = RealtimeService();
  late CargoListingModel _listing = widget.listing;
  Timer? _fallbackPollTimer;

  @override
  void initState() {
    super.initState();
    _poll();

    _realtime.connect(widget.token);
    _realtime.joinListing(_listing.id);
    _realtime.onListingUpdated((json) {
      if (!mounted) return;
      setState(() => _listing = CargoListingModel.fromJson(json));
    });
    _realtime.onListingLocation((json) {
      if (!mounted) return;
      setState(() {
        _listing = _listing.copyWithDriverLocation(
          DriverLocation(
            lat: (json['lat'] as num).toDouble(),
            lng: (json['lng'] as num).toDouble(),
            updatedAt: json['updatedAt'] as String,
          ),
        );
      });
    });

    _fallbackPollTimer = Timer.periodic(const Duration(seconds: 20), (_) => _poll());
  }

  @override
  void dispose() {
    _fallbackPollTimer?.cancel();
    _realtime.leaveListing(_listing.id);
    _realtime.dispose();
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      final updated = await _cargoApi.fetchListing(widget.token, _listing.id);
      if (!mounted) return;
      setState(() => _listing = updated);
    } catch (_) {
      // Non-fatal — skip this tick, try again on the next one.
    }
  }

  String _lastSeenLabel(AppLocalizations l10n, DriverLocation location) {
    final DateTime updatedAt = DateTime.parse(location.updatedAt);
    final int seconds = DateTime.now().difference(updatedAt).inSeconds.abs();
    return l10n.driverLastSeen(seconds);
  }

  /// Normalizes the driver's lat/lng against the pickup/dropoff bounding
  /// box for the mock map's decorative dot — not a real projection.
  Offset? _normalizedDriverOffset() {
    final DriverLocation? location = _listing.driverLocation;
    if (location == null) return null;

    final double minLat = _listing.pickup.lat < _listing.dropoff.lat
        ? _listing.pickup.lat
        : _listing.dropoff.lat;
    final double maxLat = _listing.pickup.lat > _listing.dropoff.lat
        ? _listing.pickup.lat
        : _listing.dropoff.lat;
    final double minLng = _listing.pickup.lng < _listing.dropoff.lng
        ? _listing.pickup.lng
        : _listing.dropoff.lng;
    final double maxLng = _listing.pickup.lng > _listing.dropoff.lng
        ? _listing.pickup.lng
        : _listing.dropoff.lng;

    final double latSpan = (maxLat - minLat).abs() < 0.0001 ? 1 : maxLat - minLat;
    final double lngSpan = (maxLng - minLng).abs() < 0.0001 ? 1 : maxLng - minLng;

    final double dx = ((location.lng - minLng) / lngSpan).clamp(0.05, 0.95);
    final double dy = (1 - (location.lat - minLat) / latSpan).clamp(0.05, 0.95);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DriverLocation? location = _listing.driverLocation;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(cargoTypeLabel(_listing.cargoType, l10n))),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location == null
                        ? l10n.waitingForDriverLocation
                        : _lastSeenLabel(l10n, location),
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_listing.pickup.label} → ${_listing.dropoff.label}',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: AligoMapView.isSupported
                  ? AligoMapView(
                      pickup: _listing.pickup,
                      dropoff: _listing.dropoff,
                      liveDriverPosition: location != null
                          ? GeoPoint(
                              label: l10n.driverLabel,
                              lat: location.lat,
                              lng: location.lng,
                            )
                          : null,
                    )
                  : MockMapBackground(driverPosition: _normalizedDriverOffset()),
            ),
          ],
        ),
      ),
    );
  }
}
