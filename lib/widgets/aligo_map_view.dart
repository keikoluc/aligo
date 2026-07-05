import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../core/theme/app_colors.dart';
import '../models/cargo_listing_model.dart';
import 'mock_map_background.dart';

/// Live tracking canvas for the Aligo home/tracking screens.
///
/// Renders a real Mapbox map on Android/iOS (the only platforms the
/// Mapbox Maps SDK ships native bindings for) and falls back to the
/// dependency-free [MockMapBackground] everywhere else, so desktop/web
/// builds keep working during development.
///
/// [pickup]/[dropoff] default to Tashkent placeholder coordinates when
/// omitted, matching the app's original dummy-data behavior. When
/// [liveDriverPosition] changes across rebuilds, the existing marker is
/// moved in place rather than recreated.
class AligoMapView extends StatefulWidget {
  final GeoPoint? pickup;
  final GeoPoint? dropoff;
  final GeoPoint? liveDriverPosition;

  const AligoMapView({
    super.key,
    this.pickup,
    this.dropoff,
    this.liveDriverPosition,
  });

  /// Coordinates roughly matching the dummy pickup/drop-off data used
  /// elsewhere in the app (Tashkent), used when no explicit points are
  /// supplied.
  static final Point defaultPickupPoint = Point(
    coordinates: Position(69.2925, 41.3486),
  );
  static final Point defaultDropoffPoint = Point(
    coordinates: Position(69.2360, 41.3264),
  );

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  State<AligoMapView> createState() => _AligoMapViewState();
}

class _AligoMapViewState extends State<AligoMapView> {
  CircleAnnotationManager? _manager;
  CircleAnnotation? _driverAnnotation;

  Point get _pickupPoint => widget.pickup != null
      ? Point(coordinates: Position(widget.pickup!.lng, widget.pickup!.lat))
      : AligoMapView.defaultPickupPoint;

  Point get _dropoffPoint => widget.dropoff != null
      ? Point(coordinates: Position(widget.dropoff!.lng, widget.dropoff!.lat))
      : AligoMapView.defaultDropoffPoint;

  @override
  void didUpdateWidget(covariant AligoMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.liveDriverPosition != oldWidget.liveDriverPosition) {
      _syncDriverAnnotation();
    }
  }

  Future<void> _syncDriverAnnotation() async {
    final manager = _manager;
    if (manager == null) return;

    final GeoPoint? position = widget.liveDriverPosition;
    if (position == null) {
      if (_driverAnnotation != null) {
        await manager.delete(_driverAnnotation!);
        _driverAnnotation = null;
      }
      return;
    }

    final Point point = Point(coordinates: Position(position.lng, position.lat));
    if (_driverAnnotation == null) {
      _driverAnnotation = await manager.create(
        CircleAnnotationOptions(
          geometry: point,
          circleRadius: 8,
          circleColor: AppColors.info.toARGB32(),
          circleStrokeWidth: 3,
          circleStrokeColor: Colors.white.toARGB32(),
        ),
      );
    } else {
      _driverAnnotation!.geometry = point;
      await manager.update(_driverAnnotation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AligoMapView.isSupported) {
      return const MockMapBackground();
    }

    return MapWidget(
      styleUri: MapboxStyles.MAPBOX_STREETS,
      viewport: CameraViewportState(center: _pickupPoint, zoom: 13.0),
      onMapCreated: _onMapCreated,
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    final CircleAnnotationManager manager = await mapboxMap.annotations
        .createCircleAnnotationManager();
    _manager = manager;

    await manager.createMulti([
      CircleAnnotationOptions(
        geometry: _pickupPoint,
        circleRadius: 8,
        circleColor: AppColors.slate.toARGB32(),
        circleStrokeWidth: 3,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
      CircleAnnotationOptions(
        geometry: _dropoffPoint,
        circleRadius: 9,
        circleColor: AppColors.amber.toARGB32(),
        circleStrokeWidth: 3,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
    ]);

    if (widget.liveDriverPosition != null) {
      await _syncDriverAnnotation();
    }
  }
}
