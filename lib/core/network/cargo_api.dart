import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../current_locale.dart';
import '../../models/cargo_listing_model.dart';
import 'api_exception.dart';

/// Thrown when accepting a listing fails because another driver already
/// took it, so the UI can react differently than to a generic error.
class AlreadyTakenException extends ApiException {
  const AlreadyTakenException(super.message);
}

/// Thrown when accepting a listing fails because the driver's vehicle
/// doesn't have a capability the shipper required (e.g. refrigeration).
class VehicleMismatchException extends ApiException {
  const VehicleMismatchException(super.message);
}

/// Talks to the Aligo backend's `/api/cargo` endpoints: posting listings
/// (shippers), and browsing/accepting nearby loads (drivers).
class CargoApi {
  final http.Client _client;
  final String _baseUrl;

  CargoApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.backendBaseUrl;

  Uri _endpoint(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    'X-App-Locale': currentLocaleNotifier.value.languageCode,
  };

  Map<String, dynamic> _decode(http.Response response) {
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (body['reason'] == 'already_taken') {
        throw AlreadyTakenException(
          body['error'] as String? ?? currentL10n.alreadyTaken,
        );
      }
      if (body['reason'] == 'vehicle_mismatch') {
        throw VehicleMismatchException(
          body['error'] as String? ?? currentL10n.somethingWentWrong,
        );
      }
      throw ApiException(
        body['error'] as String? ?? currentL10n.somethingWentWrong,
      );
    }
    return body;
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on http.ClientException {
      throw ApiException(currentL10n.couldNotReachServer);
    }
  }

  Future<PriceEstimate> estimatePrice({
    required String token,
    required String cargoType,
    required GeoPoint pickup,
    required GeoPoint dropoff,
    RequiredFeatures requiredFeatures = const RequiredFeatures(),
  }) async {
    final uri = _endpoint('/api/cargo/estimate').replace(
      queryParameters: {
        'cargoType': cargoType,
        'pickupLat': pickup.lat.toString(),
        'pickupLng': pickup.lng.toString(),
        'dropoffLat': dropoff.lat.toString(),
        'dropoffLng': dropoff.lng.toString(),
        for (final entry in requiredFeatures.toJson().entries)
          entry.key: entry.value.toString(),
      },
    );
    final response = await _send(
      () => _client.get(uri, headers: _headers(token)),
    );
    final body = _decode(response);
    return PriceEstimate.fromJson(body);
  }

  Future<CargoListingModel> createListing({
    required String token,
    required String cargoType,
    String? description,
    required GeoPoint pickup,
    required GeoPoint dropoff,
    required double price,
    RequiredFeatures requiredFeatures = const RequiredFeatures(),
  }) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/cargo'),
        headers: _headers(token),
        body: jsonEncode({
          'cargoType': cargoType,
          'description': description,
          'pickup': pickup.toJson(),
          'dropoff': dropoff.toJson(),
          'price': price,
          'requiredFeatures': requiredFeatures.toJson(),
        }),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }

  Future<CargoListingModel> updateListing({
    required String token,
    required String listingId,
    required String cargoType,
    String? description,
    required GeoPoint pickup,
    required GeoPoint dropoff,
    required double price,
    RequiredFeatures requiredFeatures = const RequiredFeatures(),
  }) async {
    final response = await _send(
      () => _client.put(
        _endpoint('/api/cargo/$listingId'),
        headers: _headers(token),
        body: jsonEncode({
          'cargoType': cargoType,
          'description': description,
          'pickup': pickup.toJson(),
          'dropoff': dropoff.toJson(),
          'price': price,
          'requiredFeatures': requiredFeatures.toJson(),
        }),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }

  Future<List<CargoListingModel>> fetchNearby(String token) async {
    final response = await _send(
      () =>
          _client.get(_endpoint('/api/cargo/nearby'), headers: _headers(token)),
    );
    final body = _decode(response);
    return (body['listings'] as List)
        .map((e) => CargoListingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CargoListingModel> acceptListing(
    String token,
    String listingId,
  ) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/cargo/$listingId/accept'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }

  Future<List<CargoListingModel>> fetchMine(String token) async {
    final response = await _send(
      () => _client.get(_endpoint('/api/cargo/mine'), headers: _headers(token)),
    );
    final body = _decode(response);
    return (body['listings'] as List)
        .map((e) => CargoListingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CargoListingModel> pickupListing(
    String token,
    String listingId,
  ) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/cargo/$listingId/pickup'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }

  Future<CargoListingModel> completeListing(
    String token,
    String listingId,
  ) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/cargo/$listingId/complete'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }

  Future<CargoListingModel> cancelListing(
    String token,
    String listingId,
  ) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/cargo/$listingId/cancel'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }

  Future<CargoListingModel> releaseListing(
    String token,
    String listingId,
  ) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/cargo/$listingId/release'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }

  Future<CargoListingModel> rateListing(
    String token,
    String listingId, {
    required int stars,
    String? comment,
  }) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/cargo/$listingId/rate'),
        headers: _headers(token),
        body: jsonEncode({'stars': stars, 'comment': comment}),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }

  Future<List<CargoListingModel>> fetchDeliveries(String token) async {
    final response = await _send(
      () => _client.get(
        _endpoint('/api/cargo/deliveries'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response);
    return (body['listings'] as List)
        .map((e) => CargoListingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CargoListingModel> fetchListing(String token, String listingId) async {
    final response = await _send(
      () => _client.get(
        _endpoint('/api/cargo/$listingId'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }

  Future<CargoListingModel> updateLocation(
    String token,
    String listingId,
    double lat,
    double lng,
  ) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/cargo/$listingId/location'),
        headers: _headers(token),
        body: jsonEncode({'lat': lat, 'lng': lng}),
      ),
    );
    final body = _decode(response);
    return CargoListingModel.fromJson(body['listing'] as Map<String, dynamic>);
  }
}
