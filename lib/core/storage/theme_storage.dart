import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the user's chosen appearance (light/dark/system) across launches.
class ThemeStorage {
  static const _themeModeKey = 'aligo_theme_mode';

  final FlutterSecureStorage _storage;

  ThemeStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveThemeMode(String themeMode) =>
      _storage.write(key: _themeModeKey, value: themeMode);

  Future<String?> readThemeMode() => _storage.read(key: _themeModeKey);
}
