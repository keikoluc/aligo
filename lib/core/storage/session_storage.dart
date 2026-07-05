import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Aligo session token in the platform's secure storage
/// (Keystore on Android, Keychain on iOS).
class SessionStorage {
  static const _tokenKey = 'aligo_session_token';

  final FlutterSecureStorage _storage;

  SessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
