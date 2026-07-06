import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// The latest Android build the backend knows about, used to prompt
/// sideloaded installs (no Play Store auto-update) to grab a new APK.
class AppVersionInfo {
  final int latestVersionCode;
  final String latestVersionName;
  final String downloadUrl;

  const AppVersionInfo({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.downloadUrl,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      latestVersionCode: json['latestVersionCode'] as int,
      latestVersionName: json['latestVersionName'] as String,
      downloadUrl: json['downloadUrl'] as String,
    );
  }
}

/// Talks to the Aligo backend's `/api/app/version` endpoint.
class AppVersionApi {
  final http.Client _client;
  final String _baseUrl;

  AppVersionApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.backendBaseUrl;

  /// Returns `null` on any failure — an update check is a nice-to-have,
  /// never something worth surfacing an error for or blocking on.
  Future<AppVersionInfo?> fetchLatest() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/api/app/version'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;
      return AppVersionInfo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
