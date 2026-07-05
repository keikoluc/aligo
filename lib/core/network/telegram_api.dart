import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../current_locale.dart';
import 'api_exception.dart';

/// A one-time code the shipper/driver sends to the Aligo Telegram bot
/// (or taps a deep link for) to link their chat for notifications.
class TelegramLinkCode {
  final String code;
  final int ttlMinutes;
  final String? botUsername;
  final String? deepLink;

  const TelegramLinkCode({
    required this.code,
    required this.ttlMinutes,
    this.botUsername,
    this.deepLink,
  });

  factory TelegramLinkCode.fromJson(Map<String, dynamic> json) {
    return TelegramLinkCode(
      code: json['code'] as String,
      ttlMinutes: (json['ttlMinutes'] as num).toInt(),
      botUsername: json['botUsername'] as String?,
      deepLink: json['deepLink'] as String?,
    );
  }
}

/// Talks to the Aligo backend's `/api/profile/telegram/*` endpoints.
class TelegramApi {
  final http.Client _client;
  final String _baseUrl;

  TelegramApi({http.Client? client, String? baseUrl})
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

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on http.ClientException {
      throw ApiException(currentL10n.couldNotReachServer);
    }
  }

  Future<bool> fetchStatus(String token) async {
    final response = await _send(
      () => _client.get(
        _endpoint('/api/profile/telegram/status'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response);
    return body['linked'] as bool? ?? false;
  }

  Future<TelegramLinkCode> requestLinkCode(String token) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/profile/telegram/link-code'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response);
    return TelegramLinkCode.fromJson(body);
  }

  Future<void> unlink(String token) async {
    final response = await _send(
      () => _client.post(
        _endpoint('/api/profile/telegram/unlink'),
        headers: _headers(token),
      ),
    );
    _decode(response);
  }
}
