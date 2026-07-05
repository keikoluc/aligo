import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'core/config/app_config.dart';
import 'core/current_locale.dart';
import 'core/storage/locale_storage.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth/login_screen.dart';
import 'screens/language/language_picker_screen.dart';
import 'widgets/aligo_map_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AligoMapView.isSupported) {
    MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);
  }
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Only Android has Firebase config (google-services.json) so far —
    // don't block startup on platforms without it.
  }
  runApp(const AligoApp());
}

/// Root widget of the Aligo premium logistics ecosystem.
class AligoApp extends StatefulWidget {
  const AligoApp({super.key});

  /// Switches the app's language at runtime and re-renders everything
  /// under [AligoApp] in the new locale. Call after persisting the
  /// choice with [LocaleStorage].
  static void setLocale(BuildContext context, Locale locale) {
    context.findAncestorStateOfType<_AligoAppState>()?._setLocale(locale);
  }

  @override
  State<AligoApp> createState() => _AligoAppState();
}

class _AligoAppState extends State<AligoApp> {
  final _localeStorage = LocaleStorage();
  Locale? _locale;
  bool _checkedStoredLocale = false;

  @override
  void initState() {
    super.initState();
    _loadStoredLocale();
  }

  Future<void> _loadStoredLocale() async {
    String? code;
    try {
      code = await _localeStorage.readLanguageCode();
    } catch (_) {
      // Treat a broken/unavailable secure storage the same as "no
      // choice saved yet" rather than hanging on a blank screen.
      code = null;
    }
    if (!mounted) return;
    final Locale? locale = code != null ? Locale(code) : null;
    if (locale != null) currentLocaleNotifier.value = locale;
    setState(() {
      _locale = locale;
      _checkedStoredLocale = true;
    });
  }

  void _setLocale(Locale locale) {
    currentLocaleNotifier.value = locale;
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aligo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: !_checkedStoredLocale
          ? const Scaffold(body: SizedBox.shrink())
          : (_locale == null
                ? const LanguagePickerScreen()
                : const LoginScreen()),
    );
  }
}
