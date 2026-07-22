import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'core/config/app_config.dart';
import 'core/current_locale.dart';
import 'core/network/profile_api.dart';
import 'core/storage/locale_storage.dart';
import 'core/storage/session_storage.dart';
import 'core/storage/theme_storage.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/language/language_picker_screen.dart';
import 'screens/onboarding/role_select_screen.dart';
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

  /// Switches the app's appearance (light/dark/follow system) at runtime.
  /// Call after persisting the choice with [ThemeStorage].
  static void setThemeMode(BuildContext context, ThemeMode themeMode) {
    context.findAncestorStateOfType<_AligoAppState>()?._setThemeMode(themeMode);
  }

  @override
  State<AligoApp> createState() => _AligoAppState();
}

class _AligoAppState extends State<AligoApp> {
  final _localeStorage = LocaleStorage();
  final _sessionStorage = SessionStorage();
  final _themeStorage = ThemeStorage();
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  bool _checkedStoredLocale = false;
  Widget? _initialHome;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    String? code;
    try {
      code = await _localeStorage.readLanguageCode();
    } catch (_) {
      // Treat a broken/unavailable secure storage the same as "no
      // choice saved yet" rather than hanging on a blank screen.
      code = null;
    }
    final Locale? locale = code != null ? Locale(code) : null;
    if (locale != null) currentLocaleNotifier.value = locale;

    String? themeModeName;
    try {
      themeModeName = await _themeStorage.readThemeMode();
    } catch (_) {
      themeModeName = null;
    }
    final ThemeMode themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeName,
      orElse: () => ThemeMode.system,
    );

    // Only bother resuming a session once a language is already chosen —
    // a brand-new install has no session to resume anyway.
    final Widget initialHome = locale == null
        ? const LanguagePickerScreen()
        : await _resumeSession();

    if (!mounted) return;
    setState(() {
      _locale = locale;
      _themeMode = themeMode;
      _checkedStoredLocale = true;
      _initialHome = initialHome;
    });
  }

  // The app only ever persisted the session token (SessionStorage), never
  // read it back — so every fresh launch/reload dropped a signed-in user
  // straight back onto the login screen. Resolve it against the backend
  // once at startup instead, same as any normal "remembered session".
  Future<Widget> _resumeSession() async {
    String? token;
    try {
      token = await _sessionStorage.readToken();
    } catch (_) {
      token = null;
    }
    if (token == null) return const LoginScreen();

    try {
      final UserModel user = await ProfileApi().getMe(token: token);
      return user.role == null
          ? RoleSelectScreen(token: token, user: user)
          : HomeScreen(token: token, user: user);
    } catch (_) {
      // Expired/invalid token, or unreachable backend — fall back to a
      // normal sign-in rather than getting stuck.
      await _sessionStorage.clear();
      return const LoginScreen();
    }
  }

  void _setLocale(Locale locale) {
    currentLocaleNotifier.value = locale;
    setState(() => _locale = locale);
  }

  void _setThemeMode(ThemeMode themeMode) {
    setState(() => _themeMode = themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aligo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: !_checkedStoredLocale
          ? const Scaffold(body: SizedBox.shrink())
          : _initialHome,
    );
  }
}
