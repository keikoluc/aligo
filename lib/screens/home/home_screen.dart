import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../core/current_locale.dart';
import '../../core/current_theme_mode.dart';
import '../../core/network/app_version_api.dart';
import '../../core/network/push_service.dart';
import '../../core/storage/locale_storage.dart';
import '../../core/storage/session_storage.dart';
import '../../core/storage/theme_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import '../../widgets/aligo_map_view.dart';
import '../../widgets/destination_search_bar.dart';
import '../auth/login_screen.dart';
import '../cargo/my_deliveries_screen.dart';
import '../cargo/my_shipments_screen.dart';
import '../cargo/nearby_loads_screen.dart';
import '../cargo/post_listing_screen.dart';
import '../settings/telegram_link_screen.dart';

/// Hub screen of the Aligo app: a live tracking map with a floating
/// entry point into the current user's role-specific cargo flow
/// (posting a shipment for shippers, browsing nearby loads for drivers).
class HomeScreen extends StatefulWidget {
  final String token;
  final UserModel user;

  const HomeScreen({super.key, required this.token, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool get _isShipper => widget.user.role == UserRole.shipper;

  AppVersionInfo? _updateInfo;
  bool _updateBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    registerForPushNotifications(widget.token);
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    // Only the sideloaded Android build needs this — the web build is
    // always the latest by definition, and there's no iOS build yet.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final info = await AppVersionApi().fetchLatest();
    if (!mounted || info == null) return;
    if (info.latestVersionCode > AppConfig.currentVersionCode) {
      setState(() => _updateInfo = info);
    }
  }

  void _openRoleAction() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _isShipper
            ? PostListingScreen(token: widget.token, user: widget.user)
            : NearbyLoadsScreen(token: widget.token, user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _AligoDrawer(token: widget.token, user: widget.user),
      body: Builder(
        builder: (scaffoldContext) {
          return Stack(
            children: [
              const Positioned.fill(child: AligoMapView()),
              if (!AligoMapView.isSupported) const _MapMarkers(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DestinationSearchBar(
                          onTap: _openRoleAction,
                          onMenuTap: () =>
                              Scaffold.of(scaffoldContext).openDrawer(),
                          hintText: _isShipper
                              ? AppLocalizations.of(context)!.whereToSendCargo
                              : AppLocalizations.of(context)!.findNearbyLoads,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const _ThemeQuickToggle(),
                      const SizedBox(width: AppSpacing.sm),
                      const _LanguageQuickToggle(),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: AppSpacing.md,
                bottom:
                    MediaQuery.of(context).size.height * 0.42 + AppSpacing.md,
                child: FloatingActionButton(
                  heroTag: 'locate-me',
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : AppColors.white,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  elevation: 4,
                  onPressed: () {},
                  child: const Icon(Icons.my_location),
                ),
              ),
              if (_updateInfo != null && !_updateBannerDismissed)
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: SafeArea(
                    top: false,
                    child: _UpdateBanner(
                      versionName: _updateInfo!.latestVersionName,
                      onDownload: () => launchUrl(
                        Uri.parse(_updateInfo!.downloadUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      onDismiss: () =>
                          setState(() => _updateBannerDismissed = true),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  final String versionName;
  final VoidCallback onDownload;
  final VoidCallback onDismiss;

  const _UpdateBanner({
    required this.versionName,
    required this.onDownload,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.system_update, color: AppColors.amber),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.updateAvailableTitle, style: textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    l10n.updateAvailableBody(versionName),
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onDownload,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(l10n.updateDownloadButton),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 18, color: scheme.onSurfaceVariant),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapMarkers extends StatelessWidget {
  const _MapMarkers();

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
          left: screen.width * 0.28 - 18,
          top: screen.height * 0.38 - 36,
          child: const _MapPin(
            color: AppColors.slate,
            icon: Icons.circle,
            iconSize: 12,
          ),
        ),
        Positioned(
          left: screen.width * 0.68 - 18,
          top: screen.height * 0.7 - 42,
          child: const _MapPin(
            color: AppColors.amber,
            icon: Icons.location_on,
            iconSize: 30,
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double iconSize;

  const _MapPin({
    required this.color,
    required this.icon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class _AligoDrawer extends StatelessWidget {
  final String token;
  final UserModel user;

  const _AligoDrawer({required this.token, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isShipper = user.role == UserRole.shipper;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.slate,
              child: const Icon(Icons.person, color: AppColors.amber, size: 32),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              user.fullName ?? l10n.aligoCargo,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              l10n.premiumLogisticsAccount,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: AppSpacing.xl),
            if (isShipper)
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(l10n.myShipments),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          MyShipmentsScreen(token: token, user: user),
                    ),
                  );
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(l10n.myDeliveries),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          MyDeliveriesScreen(token: token, user: user),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(l10n.paymentsInvoices),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: Text(l10n.support),
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: Text(l10n.telegramTitle),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TelegramLinkScreen(token: token, user: user),
                  ),
                );
              },
            ),
            const Divider(height: AppSpacing.xl),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(
                l10n.logout,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => _confirmLogout(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AppLocalizations l10n) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.logout,
              style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await SessionStorage().clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

/// Small circular button on the home top bar that cycles the app's
/// appearance (system → light → dark → …) in a single tap, instead of
/// sending the user to a dedicated settings screen for it.
class _ThemeQuickToggle extends StatelessWidget {
  const _ThemeQuickToggle();

  static const List<ThemeMode> _cycle = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  Future<void> _cycleTheme(BuildContext context, ThemeMode current) async {
    final ThemeMode next = _cycle[(_cycle.indexOf(current) + 1) % _cycle.length];
    await ThemeStorage().saveThemeMode(next.name);
    if (!context.mounted) return;
    AligoApp.setThemeMode(context, next);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface = isDark ? AppColors.surfaceDark : AppColors.white;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: currentThemeModeNotifier,
      builder: (context, mode, _) {
        return Material(
          color: surface,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _cycleTheme(context, mode),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(
                _iconFor(mode),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Small circular button on the home top bar that cycles the app's
/// language (uz → ru → en → …) in a single tap, instead of sending the
/// user to a dedicated language picker screen for it.
class _LanguageQuickToggle extends StatelessWidget {
  const _LanguageQuickToggle();

  static const List<String> _cycle = ['uz', 'ru', 'en'];

  Future<void> _cycleLanguage(BuildContext context, Locale current) async {
    final int index = _cycle.indexOf(current.languageCode);
    final String next = _cycle[(index + 1) % _cycle.length];
    await LocaleStorage().saveLanguageCode(next);
    if (!context.mounted) return;
    AligoApp.setLocale(context, Locale(next));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface = isDark ? AppColors.surfaceDark : AppColors.white;

    return ValueListenableBuilder<Locale>(
      valueListenable: currentLocaleNotifier,
      builder: (context, locale, _) {
        return Material(
          color: surface,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _cycleLanguage(context, locale),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                locale.languageCode.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
