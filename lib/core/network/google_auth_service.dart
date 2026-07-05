import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_config.dart';

/// Thin wrapper around `google_sign_in` v7's initialize/authenticate API,
/// returning the ID token the Aligo backend verifies to establish a
/// session.
class GoogleAuthService {
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleServerClientId,
    );
    _initialized = true;
  }

  /// Runs the interactive Google sign-in flow and returns the ID token
  /// to send to the backend, or `null` if the user canceled.
  static Future<String?> signInAndGetIdToken() async {
    await _ensureInitialized();

    final GoogleSignIn signIn = GoogleSignIn.instance;
    if (!signIn.supportsAuthenticate()) {
      throw StateError(
        'Google Sign-In is not supported on this platform via the '
        'explicit authenticate() flow (e.g. web uses a rendered button).',
      );
    }

    try {
      final GoogleSignInAccount account = await signIn.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }
}
