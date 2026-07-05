import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../current_locale.dart';
import '../../models/user_model.dart';
import 'api_exception.dart';

/// Result of a successful authentication call: a session token paired
/// with the authenticated user's profile.
class AuthResult {
  final String token;
  final UserModel user;

  const AuthResult({required this.token, required this.user});
}

/// Talks to the Aligo backend's `/api/auth` endpoints: email OTP
/// verification and Google Sign-In token exchange.
class AuthApi {
  final http.Client _client;
  final String _baseUrl;

  AuthApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.backendBaseUrl;

  Uri _endpoint(String path) => Uri.parse('$_baseUrl$path');

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

  Future<void> sendOtp(String email) async {
    final http.Response response = await _post('/api/auth/otp/send', {
      'email': email,
    });
    _decode(response);
  }

  Future<AuthResult> verifyOtp({
    required String email,
    required String code,
    String? fullName,
  }) async {
    final http.Response response = await _post('/api/auth/otp/verify', {
      'email': email,
      'code': code,
      'fullName': ?fullName,
    });
    return _toAuthResult(_decode(response));
  }

  Future<AuthResult> signInWithGoogle(String idToken) async {
    final http.Response response = await _post('/api/auth/google', {
      'idToken': idToken,
    });
    return _toAuthResult(_decode(response));
  }

  AuthResult _toAuthResult(Map<String, dynamic> body) {
    return AuthResult(
      token: body['token'] as String,
      user: UserModel.fromJson(body['user'] as Map<String, dynamic>),
    );
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    try {
      return await _client.post(
        _endpoint(path),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Locale': currentLocaleNotifier.value.languageCode,
        },
        body: jsonEncode(body),
      );
    } on http.ClientException {
      throw ApiException(currentL10n.couldNotReachServer);
    }
  }
}
