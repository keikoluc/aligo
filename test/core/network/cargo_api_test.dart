import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aligo/core/current_locale.dart';
import 'package:aligo/core/network/api_exception.dart';
import 'package:aligo/core/network/cargo_api.dart';
import 'package:aligo/models/cargo_listing_model.dart';

http.Response _json(Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response(jsonEncode(body), statusCode);
}

const _pickup = GeoPoint(label: 'A', lat: 41.3, lng: 69.24);
const _dropoff = GeoPoint(label: 'B', lat: 41.33, lng: 69.28);

Map<String, dynamic> _listingJson({String status = 'open'}) => {
  'id': 1,
  'cargoType': 'general',
  'description': null,
  'pickup': _pickup.toJson(),
  'dropoff': _dropoff.toJson(),
  'price': 50000,
  'status': status,
  'createdAt': '2026-07-04T10:00:00.000Z',
};

void main() {
  // Fallback error messages are localized (see currentLocaleNotifier) —
  // pin to English so assertions below stay readable and deterministic.
  setUp(() => currentLocaleNotifier.value = const Locale('en'));

  group('estimatePrice', () {
    test('sends coordinates as query params and parses the estimate', () async {
      late Uri capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return _json({'distanceKm': 9.0, 'durationMin': 19.1, 'suggestedPrice': 53000});
      });
      final api = CargoApi(client: client, baseUrl: 'http://test');

      final estimate = await api.estimatePrice(
        token: 't',
        cargoType: 'furniture',
        pickup: _pickup,
        dropoff: _dropoff,
      );

      expect(estimate.suggestedPrice, 53000.0);
      expect(capturedUri.path, '/api/cargo/estimate');
      expect(capturedUri.queryParameters['cargoType'], 'furniture');
      expect(capturedUri.queryParameters['pickupLat'], _pickup.lat.toString());
    });
  });

  group('createListing', () {
    test('posts the listing payload and returns the created model', () async {
      final client = MockClient((request) async {
        final sent = jsonDecode(request.body) as Map<String, dynamic>;
        expect(sent['cargoType'], 'general');
        expect(sent['price'], 50000);
        return _json({'listing': _listingJson()}, statusCode: 201);
      });
      final api = CargoApi(client: client, baseUrl: 'http://test');

      final listing = await api.createListing(
        token: 't',
        cargoType: 'general',
        pickup: _pickup,
        dropoff: _dropoff,
        price: 50000,
      );

      expect(listing.cargoType, 'general');
      expect(listing.status, CargoListingStatus.open);
    });

    test('throws ApiException with the server message on failure', () async {
      final client = MockClient((request) async {
        return _json({'error': 'Price must be a positive number.'}, statusCode: 400);
      });
      final api = CargoApi(client: client, baseUrl: 'http://test');

      await expectLater(
        api.createListing(
          token: 't',
          cargoType: 'general',
          pickup: _pickup,
          dropoff: _dropoff,
          price: -1,
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Price must be a positive number.',
          ),
        ),
      );
    });
  });

  group('acceptListing', () {
    test('throws AlreadyTakenException when reason is already_taken', () async {
      final client = MockClient((request) async {
        return _json(
          {'error': 'This load was already accepted by another driver.', 'reason': 'already_taken'},
          statusCode: 409,
        );
      });
      final api = CargoApi(client: client, baseUrl: 'http://test');

      await expectLater(
        api.acceptListing('t', '1'),
        throwsA(isA<AlreadyTakenException>()),
      );
    });

    test('returns the updated listing on success', () async {
      final client = MockClient((request) async {
        return _json({'listing': _listingJson(status: 'accepted')});
      });
      final api = CargoApi(client: client, baseUrl: 'http://test');

      final listing = await api.acceptListing('t', '1');
      expect(listing.status, CargoListingStatus.accepted);
    });
  });

  group('fetchNearby', () {
    test('parses a list of listings', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/cargo/nearby');
        return _json({
          'listings': [_listingJson(), _listingJson()],
        });
      });
      final api = CargoApi(client: client, baseUrl: 'http://test');

      final listings = await api.fetchNearby('t');
      expect(listings.length, 2);
    });
  });

  group('network failure', () {
    test('wraps a ClientException in a friendly ApiException', () async {
      final client = MockClient((request) async {
        throw http.ClientException('Connection refused');
      });
      final api = CargoApi(client: client, baseUrl: 'http://test');

      await expectLater(
        api.fetchNearby('t'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Could not reach'),
          ),
        ),
      );
    });
  });
}
