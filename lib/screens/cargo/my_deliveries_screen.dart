import 'package:flutter/material.dart';

import '../../core/cargo_categories.dart';
import '../../core/location/location_reporter.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/cargo_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cargo_listing_model.dart';
import '../../models/user_model.dart';
import '../../widgets/cargo_status_pill.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rating_dialog.dart';
import '../../widgets/required_features_row.dart';

/// Driver flow: lists the loads this user has accepted, with the
/// shipper's contact details, a way to mark a delivery complete, and a
/// toggle to share live location with the shipper while en route.
class MyDeliveriesScreen extends StatefulWidget {
  final String token;
  final UserModel user;

  const MyDeliveriesScreen({
    super.key,
    required this.token,
    required this.user,
  });

  @override
  State<MyDeliveriesScreen> createState() => _MyDeliveriesScreenState();
}

class _MyDeliveriesScreenState extends State<MyDeliveriesScreen> {
  final _cargoApi = CargoApi();
  final _reporter = LocationReporter();
  late Future<List<CargoListingModel>> _listingsFuture;
  final Set<String> _busyIds = {};

  // A driver only has one physical location, so at most one delivery can
  // be shared at a time. Sharing is scoped to this screen being open —
  // there's no background service, so leaving the screen always stops it.
  String? _sharingListingId;

  @override
  void initState() {
    super.initState();
    _listingsFuture = _cargoApi.fetchDeliveries(widget.token);
  }

  @override
  void dispose() {
    _reporter.stop();
    super.dispose();
  }

  void _refresh() {
    setState(() => _listingsFuture = _cargoApi.fetchDeliveries(widget.token));
  }

  Future<void> _toggleSharing(CargoListingModel listing) async {
    if (_sharingListingId == listing.id) {
      _reporter.stop();
      setState(() => _sharingListingId = null);
      return;
    }

    _reporter.stop();
    final bool started = await _reporter.start(widget.token, listing.id);
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.locationPermissionRequired),
        ),
      );
      return;
    }
    setState(() => _sharingListingId = listing.id);
  }

  Future<void> _runAction(
    CargoListingModel listing,
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() => _busyIds.add(listing.id));
    try {
      await action();
      if (!mounted) return;
      if (_sharingListingId == listing.id) {
        _reporter.stop();
        _sharingListingId = null;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busyIds.remove(listing.id));
    }
  }

  Future<void> _markPickedUp(CargoListingModel listing) => _runAction(
    listing,
    () => _cargoApi.pickupListing(widget.token, listing.id),
    AppLocalizations.of(context)!.markedPickedUp,
  );

  Future<void> _markDelivered(CargoListingModel listing) => _runAction(
    listing,
    () => _cargoApi.completeListing(widget.token, listing.id),
    AppLocalizations.of(context)!.markedDelivered,
  );

  Future<void> _release(CargoListingModel listing) => _runAction(
    listing,
    () => _cargoApi.releaseListing(widget.token, listing.id),
    AppLocalizations.of(context)!.deliveryReleased,
  );

  Future<void> _rateShipper(CargoListingModel listing) async {
    final result = await showRatingDialog(
      context,
      title: AppLocalizations.of(context)!.rateShipperTitle,
    );
    if (result == null) return;
    final (stars, comment) = result;
    if (!mounted) return;
    await _runAction(
      listing,
      () => _cargoApi.rateListing(
        widget.token,
        listing.id,
        stars: stars,
        comment: comment,
      ),
      AppLocalizations.of(context)!.thanksForRating,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myDeliveriesTitle)),
      body: SafeArea(
        child: FutureBuilder<List<CargoListingModel>>(
          future: _listingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : l10n.somethingWentWrong;
              return Center(child: Text(message));
            }
            final listings = snapshot.data ?? [];
            if (listings.isEmpty) {
              return Center(child: Text(l10n.noDeliveriesYet));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final listing = listings[index];
                return _DeliveryCard(
                  listing: listing,
                  isBusy: _busyIds.contains(listing.id),
                  isSharing: _sharingListingId == listing.id,
                  onMarkPickedUp: () => _markPickedUp(listing),
                  onMarkDelivered: () => _markDelivered(listing),
                  onRelease: () => _release(listing),
                  onRateShipper: () => _rateShipper(listing),
                  onToggleSharing: () => _toggleSharing(listing),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final CargoListingModel listing;
  final bool isBusy;
  final bool isSharing;
  final VoidCallback onMarkPickedUp;
  final VoidCallback onMarkDelivered;
  final VoidCallback onRelease;
  final VoidCallback onRateShipper;
  final VoidCallback onToggleSharing;

  const _DeliveryCard({
    required this.listing,
    required this.isBusy,
    required this.isSharing,
    required this.onMarkPickedUp,
    required this.onMarkDelivered,
    required this.onRelease,
    required this.onRateShipper,
    required this.onToggleSharing,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isAccepted = listing.status == CargoListingStatus.accepted;
    final bool isInTransit = listing.status == CargoListingStatus.inTransit;
    final bool isCompleted = listing.status == CargoListingStatus.completed;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slateLight : AppColors.offWhite,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cargoTypeLabel(listing.cargoType, l10n),
                  style: textTheme.titleMedium,
                ),
              ),
              CargoStatusPill(status: listing.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${listing.pickup.label} → ${listing.dropoff.label}',
            style: textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            listing.price.toStringAsFixed(0),
            style: textTheme.titleMedium?.copyWith(color: scheme.secondary),
          ),
          if (!listing.requiredFeatures.isEmpty) ...[
            const SizedBox(height: 8),
            RequiredFeaturesRow(requiredFeatures: listing.requiredFeatures),
          ],
          if (listing.shipper != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${listing.shipper!.fullName ?? l10n.shipperFallback} · ${listing.shipper!.phone ?? ''}'
                    '${listing.shipper!.ratingAvg != null ? ' · ★${listing.shipper!.ratingAvg!.toStringAsFixed(1)}' : ''}',
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (isAccepted || isInTransit) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Switch(value: isSharing, onChanged: (_) => onToggleSharing()),
                Expanded(
                  child: Text(
                    isSharing ? l10n.sharingLiveLocation : l10n.shareMyLocation,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isSharing ? AppColors.info : null,
                      fontWeight: isSharing ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
            if (isSharing)
              Text(l10n.sharingStopsIfLeave, style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: isAccepted ? l10n.pickedUpCargo : l10n.markAsDelivered,
              isLoading: isBusy,
              onPressed: isAccepted ? onMarkPickedUp : onMarkDelivered,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: isBusy ? null : onRelease,
              child: Text(l10n.releaseThisDelivery),
            ),
          ],
          if (isCompleted) ...[
            const SizedBox(height: AppSpacing.sm),
            if (listing.myRating != null)
              Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    l10n.ratedShipperStars(listing.myRating!.stars),
                    style: textTheme.bodySmall,
                  ),
                ],
              )
            else
              PrimaryButton(
                label: l10n.rateShipperButton,
                isLoading: isBusy,
                onPressed: onRateShipper,
              ),
          ],
        ],
      ),
    );
  }
}
