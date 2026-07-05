import 'package:flutter_test/flutter_test.dart';
import 'package:aligo/models/cargo_listing_model.dart';
import 'package:aligo/models/driver_vehicle_model.dart';

void main() {
  group('RequiredFeatures', () {
    test('fromJson picks out only the true-valued features', () {
      final features = RequiredFeatures.fromJson({
        'refrigerated': true,
        'sideRearTent': false,
        'lift': true,
        'tieDownStraps': false,
      });
      expect(features.contains(VehicleAmenity.refrigerated), isTrue);
      expect(features.contains(VehicleAmenity.sideRearTent), isFalse);
      expect(features.contains(VehicleAmenity.lift), isTrue);
      expect(features.isEmpty, isFalse);
    });

    test('an all-false JSON payload parses to an empty set', () {
      final features = RequiredFeatures.fromJson({
        'refrigerated': false,
        'sideRearTent': false,
        'lift': false,
        'tieDownStraps': false,
      });
      expect(features.isEmpty, isTrue);
    });

    test('toJson round-trips through fromJson', () {
      const original = RequiredFeatures(
        features: {VehicleAmenity.lift, VehicleAmenity.tieDownStraps},
      );
      final rebuilt = RequiredFeatures.fromJson(original.toJson());
      expect(rebuilt.contains(VehicleAmenity.lift), isTrue);
      expect(rebuilt.contains(VehicleAmenity.tieDownStraps), isTrue);
      expect(rebuilt.contains(VehicleAmenity.refrigerated), isFalse);
    });
  });
  group('CargoListingStatus.fromApiValue', () {
    test('maps known API values to the right enum case', () {
      expect(CargoListingStatus.fromApiValue('open'), CargoListingStatus.open);
      expect(
        CargoListingStatus.fromApiValue('accepted'),
        CargoListingStatus.accepted,
      );
      expect(
        CargoListingStatus.fromApiValue('in_transit'),
        CargoListingStatus.inTransit,
      );
      expect(
        CargoListingStatus.fromApiValue('completed'),
        CargoListingStatus.completed,
      );
      expect(
        CargoListingStatus.fromApiValue('cancelled'),
        CargoListingStatus.cancelled,
      );
    });

    test('falls back to open for an unrecognized value', () {
      expect(
        CargoListingStatus.fromApiValue('something-new'),
        CargoListingStatus.open,
      );
    });
  });

  group('GeoPoint', () {
    test('round-trips through toJson/fromJson', () {
      const point = GeoPoint(label: 'Tashkent', lat: 41.31, lng: 69.24);
      final rebuilt = GeoPoint.fromJson(point.toJson());
      expect(rebuilt.label, point.label);
      expect(rebuilt.lat, point.lat);
      expect(rebuilt.lng, point.lng);
    });
  });

  group('ContactInfo.fromJson', () {
    test('parses rating fields when present', () {
      final contact = ContactInfo.fromJson({
        'fullName': 'Driver Name',
        'phone': '+998900000000',
        'ratingAvg': 4.5,
        'ratingCount': 3,
      });
      expect(contact.fullName, 'Driver Name');
      expect(contact.ratingAvg, 4.5);
      expect(contact.ratingCount, 3);
    });

    test('defaults ratingCount to 0 when absent', () {
      final contact = ContactInfo.fromJson({
        'fullName': 'Driver Name',
        'phone': null,
      });
      expect(contact.ratingAvg, isNull);
      expect(contact.ratingCount, 0);
    });
  });

  group('CargoListingModel.fromJson', () {
    Map<String, dynamic> baseJson({
      String status = 'open',
      Map<String, dynamic>? shipper,
      Map<String, dynamic>? driver,
      Map<String, dynamic>? driverLocation,
      Map<String, dynamic>? myRating,
      Map<String, dynamic>? requiredFeatures,
    }) {
      return {
        'id': 42,
        'cargoType': 'furniture',
        'description': 'Sofa and chairs',
        'pickup': {'label': 'A', 'lat': 41.3, 'lng': 69.24},
        'dropoff': {'label': 'B', 'lat': 41.33, 'lng': 69.28},
        'price': 75000,
        'status': status,
        'distanceKm': 9.4,
        'createdAt': '2026-07-04T10:00:00.000Z',
        'shipper': shipper,
        'driver': driver,
        'driverLocation': driverLocation,
        'myRating': myRating,
        'requiredFeatures': requiredFeatures,
      };
    }

    test('parses a minimal open listing with no matched party yet', () {
      final listing = CargoListingModel.fromJson(baseJson());

      expect(listing.id, '42');
      expect(listing.cargoType, 'furniture');
      expect(listing.status, CargoListingStatus.open);
      expect(listing.price, 75000.0);
      expect(listing.shipper, isNull);
      expect(listing.driver, isNull);
      expect(listing.driverLocation, isNull);
      expect(listing.myRating, isNull);
      expect(listing.requiredFeatures.isEmpty, isTrue);
    });

    test('parses required vehicle features when present', () {
      final listing = CargoListingModel.fromJson(
        baseJson(
          requiredFeatures: {
            'refrigerated': true,
            'sideRearTent': false,
            'lift': false,
            'tieDownStraps': false,
          },
        ),
      );
      expect(
        listing.requiredFeatures.contains(VehicleAmenity.refrigerated),
        isTrue,
      );
      expect(listing.requiredFeatures.contains(VehicleAmenity.lift), isFalse);
    });

    test('parses a matched, in-transit listing with driver location', () {
      final listing = CargoListingModel.fromJson(
        baseJson(
          status: 'in_transit',
          driver: {
            'fullName': 'Driver Name',
            'phone': '+998900000000',
            'ratingAvg': 4.8,
            'ratingCount': 10,
          },
          driverLocation: {
            'lat': 41.315,
            'lng': 69.25,
            'updatedAt': '2026-07-04T10:05:00.000Z',
          },
        ),
      );

      expect(listing.status, CargoListingStatus.inTransit);
      expect(listing.driver!.fullName, 'Driver Name');
      expect(listing.driver!.ratingAvg, 4.8);
      expect(listing.driverLocation!.lat, 41.315);
    });

    test('parses myRating when the current user has already rated', () {
      final listing = CargoListingModel.fromJson(
        baseJson(status: 'completed', myRating: {'stars': 5, 'comment': 'Great!'}),
      );
      expect(listing.myRating!.stars, 5);
      expect(listing.myRating!.comment, 'Great!');
    });
  });

  group('CargoListingModel.copyWithDriverLocation', () {
    test('replaces only the driver location, keeping everything else', () {
      const listing = CargoListingModel(
        id: '1',
        cargoType: 'general',
        pickup: GeoPoint(label: 'A', lat: 41.3, lng: 69.24),
        dropoff: GeoPoint(label: 'B', lat: 41.33, lng: 69.28),
        price: 50000,
        status: CargoListingStatus.accepted,
        createdAt: '2026-07-04T10:00:00.000Z',
      );

      final updated = listing.copyWithDriverLocation(
        const DriverLocation(
          lat: 41.32,
          lng: 69.26,
          updatedAt: '2026-07-04T10:10:00.000Z',
        ),
      );

      expect(updated.driverLocation!.lat, 41.32);
      expect(updated.id, listing.id);
      expect(updated.status, listing.status);
      expect(updated.price, listing.price);
    });
  });

  group('PriceEstimate.fromJson', () {
    test('parses distance, duration, and suggested price', () {
      final estimate = PriceEstimate.fromJson({
        'distanceKm': 9.0,
        'durationMin': 19.1,
        'suggestedPrice': 53000,
      });
      expect(estimate.distanceKm, 9.0);
      expect(estimate.durationMin, 19.1);
      expect(estimate.suggestedPrice, 53000.0);
    });
  });
}
