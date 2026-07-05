import '../l10n/app_localizations.dart';

/// Optional cargo-handling features a driver's vehicle may offer.
enum VehicleAmenity {
  refrigerated,
  sideRearTent,
  lift,
  tieDownStraps;

  String get apiKey {
    switch (this) {
      case VehicleAmenity.refrigerated:
        return 'refrigerated';
      case VehicleAmenity.sideRearTent:
        return 'sideRearTent';
      case VehicleAmenity.lift:
        return 'lift';
      case VehicleAmenity.tieDownStraps:
        return 'tieDownStraps';
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case VehicleAmenity.refrigerated:
        return l10n.amenityRefrigerated;
      case VehicleAmenity.sideRearTent:
        return l10n.amenitySideRearTent;
      case VehicleAmenity.lift:
        return l10n.amenityLift;
      case VehicleAmenity.tieDownStraps:
        return l10n.amenityTieDownStraps;
    }
  }
}

/// A driver's registered vehicle, submitted once during onboarding.
class DriverVehicleModel {
  final String brandModel;
  final String color;
  final String plateNumber;
  final String sizeLabel;
  final Set<VehicleAmenity> amenities;

  const DriverVehicleModel({
    required this.brandModel,
    required this.color,
    required this.plateNumber,
    required this.sizeLabel,
    this.amenities = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'brandModel': brandModel,
      'color': color,
      'plateNumber': plateNumber,
      'sizeLabel': sizeLabel,
      'amenities': {
        for (final amenity in VehicleAmenity.values)
          amenity.apiKey: amenities.contains(amenity),
      },
    };
  }
}
