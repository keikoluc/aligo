import 'driver_vehicle_model.dart';

/// A route-distance-based price suggestion for a not-yet-created listing.
class PriceEstimate {
  final double distanceKm;
  final double durationMin;
  final double suggestedPrice;

  const PriceEstimate({
    required this.distanceKm,
    required this.durationMin,
    required this.suggestedPrice,
  });

  factory PriceEstimate.fromJson(Map<String, dynamic> json) {
    return PriceEstimate(
      distanceKm: (json['distanceKm'] as num).toDouble(),
      durationMin: (json['durationMin'] as num).toDouble(),
      suggestedPrice: (json['suggestedPrice'] as num).toDouble(),
    );
  }
}

/// A named point with coordinates — a cargo listing's pickup or dropoff.
class GeoPoint {
  final String label;
  final double lat;
  final double lng;

  const GeoPoint({required this.label, required this.lat, required this.lng});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      label: json['label'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'lat': lat, 'lng': lng};
}

/// Lifecycle state of a cargo listing.
enum CargoListingStatus {
  open,
  accepted,
  inTransit,
  completed,
  cancelled;

  static CargoListingStatus fromApiValue(String value) {
    switch (value) {
      case 'accepted':
        return CargoListingStatus.accepted;
      case 'in_transit':
        return CargoListingStatus.inTransit;
      case 'completed':
        return CargoListingStatus.completed;
      case 'cancelled':
        return CargoListingStatus.cancelled;
      default:
        return CargoListingStatus.open;
    }
  }
}

/// Contact details revealed once a listing's two parties are matched,
/// including their aggregate rating from past deliveries.
class ContactInfo {
  final String? fullName;
  final String? phone;
  final double? ratingAvg;
  final int ratingCount;

  const ContactInfo({
    this.fullName,
    this.phone,
    this.ratingAvg,
    this.ratingCount = 0,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A rating the current user has already submitted for a listing.
class MyRating {
  final int stars;
  final String? comment;

  const MyRating({required this.stars, this.comment});

  factory MyRating.fromJson(Map<String, dynamic> json) {
    return MyRating(
      stars: (json['stars'] as num).toInt(),
      comment: json['comment'] as String?,
    );
  }
}

/// Vehicle capabilities a shipper requires for a listing — reuses
/// [VehicleAmenity] so a driver's own vehicle amenities can be checked
/// against it directly (see [VehicleAmenity.apiKey]).
class RequiredFeatures {
  final Set<VehicleAmenity> features;

  const RequiredFeatures({this.features = const {}});

  bool contains(VehicleAmenity amenity) => features.contains(amenity);
  bool get isEmpty => features.isEmpty;

  factory RequiredFeatures.fromJson(Map<String, dynamic> json) {
    return RequiredFeatures(
      features: {
        for (final amenity in VehicleAmenity.values)
          if (json[amenity.apiKey] == true) amenity,
      },
    );
  }

  Map<String, dynamic> toJson() => {
    for (final amenity in VehicleAmenity.values)
      amenity.apiKey: features.contains(amenity),
  };
}

/// The driver's most recently reported GPS position for a delivery.
class DriverLocation {
  final double lat;
  final double lng;
  final String updatedAt;

  const DriverLocation({
    required this.lat,
    required this.lng,
    required this.updatedAt,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      updatedAt: json['updatedAt'] as String,
    );
  }
}

/// A shipper's posted cargo listing, optionally annotated with the
/// requesting driver's distance to the pickup point.
class CargoListingModel {
  final String id;
  final String cargoType;
  final String? description;
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final double price;
  final CargoListingStatus status;
  final double? distanceKm;
  final String createdAt;
  final ContactInfo? shipper;
  final ContactInfo? driver;
  final DriverLocation? driverLocation;
  final MyRating? myRating;
  final RequiredFeatures requiredFeatures;

  const CargoListingModel({
    required this.id,
    required this.cargoType,
    this.description,
    required this.pickup,
    required this.dropoff,
    required this.price,
    required this.status,
    this.distanceKm,
    required this.createdAt,
    this.shipper,
    this.driver,
    this.driverLocation,
    this.myRating,
    this.requiredFeatures = const RequiredFeatures(),
  });

  factory CargoListingModel.fromJson(Map<String, dynamic> json) {
    return CargoListingModel(
      id: json['id'].toString(),
      cargoType: json['cargoType'] as String,
      description: json['description'] as String?,
      pickup: GeoPoint.fromJson(json['pickup'] as Map<String, dynamic>),
      dropoff: GeoPoint.fromJson(json['dropoff'] as Map<String, dynamic>),
      price: (json['price'] as num).toDouble(),
      status: CargoListingStatus.fromApiValue(json['status'] as String),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String,
      shipper: json['shipper'] != null
          ? ContactInfo.fromJson(json['shipper'] as Map<String, dynamic>)
          : null,
      driver: json['driver'] != null
          ? ContactInfo.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      driverLocation: json['driverLocation'] != null
          ? DriverLocation.fromJson(json['driverLocation'] as Map<String, dynamic>)
          : null,
      requiredFeatures: json['requiredFeatures'] != null
          ? RequiredFeatures.fromJson(
              json['requiredFeatures'] as Map<String, dynamic>,
            )
          : const RequiredFeatures(),
      myRating: json['myRating'] != null
          ? MyRating.fromJson(json['myRating'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Used to apply a `listing:location` realtime update without
  /// refetching the whole listing over REST.
  CargoListingModel copyWithDriverLocation(DriverLocation location) {
    return CargoListingModel(
      id: id,
      cargoType: cargoType,
      description: description,
      pickup: pickup,
      dropoff: dropoff,
      price: price,
      status: status,
      distanceKm: distanceKm,
      createdAt: createdAt,
      shipper: shipper,
      driver: driver,
      driverLocation: location,
      myRating: myRating,
      requiredFeatures: requiredFeatures,
    );
  }
}
