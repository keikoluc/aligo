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
  static String get backendBaseUrl {
    return 'https://api.aligoo.uz';
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

  /// Must match the Android `versionCode` this build ships with (see
  /// pubspec.yaml's `version: name+code` and android/app/build.gradle.kts),
  /// so the app can tell it's outdated against `/api/app/version`. Since
  /// the app is sideloaded (no Play Store auto-update), bump this by hand
  /// alongside pubspec.yaml and backend/src/config/appVersion.js whenever
  /// a new APK is uploaded to /download.
  static const int currentVersionCode = 1;
}
