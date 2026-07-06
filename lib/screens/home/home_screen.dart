import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    registerForPushNotifications(widget.token);
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
            ],
          );
        },
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
