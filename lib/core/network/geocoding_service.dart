import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// A single forward-geocoding match: a human-readable label plus the
/// coordinates it resolves to.
class GeocodingCandidate {
  final String label;
  final double lat;
  final double lng;

  const GeocodingCandidate({
    required this.label,
    required this.lat,
    required this.lng,
  });
}

/// Resolves free-text addresses to coordinates via Mapbox's forward
/// geocoding REST API, using the same public access token already used
/// for map rendering elsewhere in the app.
class GeocodingService {
  final http.Client _client;

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<GeocodingCandidate>> search(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final Uri uri = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/'
      '${Uri.encodeComponent(trimmed)}.json'
      '?access_token=${AppConfig.mapboxAccessToken}&limit=5',
    );

    try {
      final http.Response response = await _client.get(uri);
      if (response.statusCode != 200) return [];

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> features = (body['features'] as List?) ?? [];

      return features.map((feature) {
        final Map<String, dynamic> f = feature as Map<String, dynamic>;
        final List<dynamic> center = f['center'] as List;
        return GeocodingCandidate(
          label: f['place_name'] as String,
          lng: (center[0] as num).toDouble(),
          lat: (center[1] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
