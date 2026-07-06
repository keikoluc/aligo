import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../core/network/app_version_api.dart';
import '../../core/network/push_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../widgets/aligo_map_view.dart';
import '../../widgets/destination_search_bar.dart';
import '../cargo/my_deliveries_screen.dart';
import '../cargo/my_shipments_screen.dart';
import '../cargo/nearby_loads_screen.dart';
import '../cargo/post_listing_screen.dart';
import '../language/language_picker_screen.dart';
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
                  child: DestinationSearchBar(
                    onTap: _openRoleAction,
                    onMenuTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                    hintText: _isShipper
                        ? AppLocalizations.of(context)!.whereToSendCargo
                        : AppLocalizations.of(context)!.findNearbyLoads,
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
              child: const Icon(
                Icons.person,
                color: AppColors.amber,
                size: 32,
              ),
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
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const LanguagePickerScreen(isInitialSetup: false),
                  ),
                );
              },
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
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settings),
            ),
          ],
        ),
      ),
    );
  }
}
