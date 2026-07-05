import 'package:firebase_messaging/firebase_messaging.dart';

import 'profile_api.dart';

/// Requests notification permission, fetches this device's FCM token,
/// and registers it with the backend so it can push status updates
/// (accepted, picked up, delivered, rated) to the right user.
///
/// Best-effort only: pushes are a nice-to-have, so any failure here
/// (permission denied, no Firebase config on this platform, network
/// error) is swallowed rather than surfaced to the caller.
Future<void> registerForPushNotifications(String authToken) async {
  try {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    final fcmToken = await messaging.getToken();
    if (fcmToken == null) return;

    final profileApi = ProfileApi();
    await profileApi.registerPushToken(token: authToken, fcmToken: fcmToken);

    messaging.onTokenRefresh.listen((newToken) {
      profileApi.registerPushToken(token: authToken, fcmToken: newToken);
    });
  } catch (_) {
    // Non-fatal — the app works fine without push notifications.
  }
}
