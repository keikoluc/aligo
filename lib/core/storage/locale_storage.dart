import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the user's chosen app language across launches.
class LocaleStorage {
  static const _localeKey = 'aligo_locale';

  final FlutterSecureStorage _storage;

  LocaleStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveLanguageCode(String languageCode) =>
      _storage.write(key: _localeKey, value: languageCode);

  Future<String?> readLanguageCode() => _storage.read(key: _localeKey);
}
