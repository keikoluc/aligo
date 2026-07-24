import 'package:web/web.dart' as web;

/// Reads a `?token=` handed off from the landing page's own login modal
/// (aligoo.uz) after it verifies an OTP, so opening /app/ signs the user
/// straight in instead of asking for email again. Strips it from the
/// address bar immediately so the token doesn't linger in browser
/// history.
String? consumeHandoffToken() {
  final Uri uri = Uri.base;
  final String? token = uri.queryParameters['token'];
  if (token == null || token.isEmpty) return null;

  final Map<String, String> remaining = Map<String, String>.from(
    uri.queryParameters,
  )..remove('token');
  final Uri cleaned = uri.replace(
    queryParameters: remaining.isEmpty ? null : remaining,
  );
  web.window.history.replaceState(null, '', cleaned.toString());
  return token;
}
