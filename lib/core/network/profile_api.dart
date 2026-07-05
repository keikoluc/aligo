import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../current_locale.dart';
import '../../models/driver_vehicle_model.dart';
import '../../models/user_model.dart';
import 'api_exception.dart';

/// Talks to the Aligo backend's `/api/profile` endpoint: saving the
/// role/profile data collected during onboarding.
class ProfileApi {
  final http.Client _client;
  final String _baseUrl;

  ProfileApi({http.Client? client, String? baseUrl})
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
      throw ApiException(
        body['error'] as String? ?? currentL10n.somethingWentWrong,
      );
    }
    return body;
  }

  Future<UserModel> saveProfile({
    required String token,
    required UserRole role,
    required String fullName,
    required String phone,
    required String address,
    required int age,
    DriverVehicleModel? vehicle,
    double? lat,
    double? lng,
  }) async {
    final http.Response response;
    try {
      response = await _client.put(
        _endpoint('/api/profile'),
        headers: _headers(token),
        body: jsonEncode({
          'role': role.apiValue,
          'fullName': fullName,
          'phone': phone,
          'address': address,
          'age': age,
          if (vehicle != null) 'vehicle': vehicle.toJson(),
          'lat': ?lat,
          'lng': ?lng,
        }),
      );
    } on http.ClientException {
      throw ApiException(currentL10n.couldNotReachServer);
    }

    final Map<String, dynamic> body = _decode(response);
    return UserModel.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<void> registerPushToken({
    required String token,
    required String fcmToken,
  }) async {
    final http.Response response;
    try {
      response = await _client.put(
        _endpoint('/api/profile/push-token'),
        headers: _headers(token),
        body: jsonEncode({'fcmToken': fcmToken}),
      );
    } on http.ClientException {
      throw ApiException(currentL10n.couldNotReachServer);
    }
    _decode(response);
  }
}
