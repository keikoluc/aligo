import 'package:flutter/foundation.dart';

/// Runtime configuration for the Aligo client.
///
/// Only public, client-safe identifiers live here (backend URL, OAuth
/// client ID used purely to request an ID token, and a public Mapbox
/// access token). Secrets such as the Gmail app password and the Google
/// OAuth client secret stay on the backend and are never shipped in the
/// app binary.
class AppConfig {
  AppConfig._();

  /// Base URL of the Aligo auth backend.
  ///
  /// A physical Android device can't reach the dev machine via
  /// `localhost`, so it uses the dev machine's LAN IP instead. Both
  /// devices must be on the same Wi-Fi network.
  static String get backendBaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.89.26:4000';
    }
    return 'http://localhost:4000';
  }

  /// OAuth "server" client ID. Passed to google_sign_in as the
  /// `serverClientId` so the returned ID token's audience matches what
  /// the backend verifies with `google-auth-library`.
  static const String googleServerClientId =
      '147548253671-mpnati81od4s492c16o0kcs8mqbv5dlt.apps.googleusercontent.com';

  /// Public Mapbox access token (safe for client-side use), scoped with
  /// URL restrictions in the Mapbox dashboard.
  static const String mapboxAccessToken =
      'pk.eyJ1Ijoia2Vpa29sdWMiLCJhIjoiY21yNzNmcnN2MHlrMzJ5cXJsbzI5dG1ubSJ9.IUM29uRGwwPtb3m2jZKjoQ';
}
