import 'package:flutter/material.dart';

import '../../core/cargo_categories.dart';
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
import 'post_listing_screen.dart';
import 'shipment_detail_screen.dart';

/// Shipper flow: lists the shipments this user has posted, with their
/// current status.
class MyShipmentsScreen extends StatefulWidget {
  final String token;
  final UserModel user;

  const MyShipmentsScreen({
    super.key,
    required this.token,
    required this.user,
  });

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen> {
  final _cargoApi = CargoApi();
  late Future<List<CargoListingModel>> _listingsFuture;
  final Set<String> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _listingsFuture = _cargoApi.fetchMine(widget.token);
  }

  void _refresh() {
    setState(() => _listingsFuture = _cargoApi.fetchMine(widget.token));
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

  Future<void> _cancel(CargoListingModel listing) => _runAction(
    listing,
    () => _cargoApi.cancelListing(widget.token, listing.id),
    AppLocalizations.of(context)!.shipmentCancelled,
  );

  Future<void> _rateDriver(CargoListingModel listing) async {
    final result = await showRatingDialog(
      context,
      title: AppLocalizations.of(context)!.rateDriverTitle,
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
      appBar: AppBar(title: Text(l10n.myShipmentsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  PostListingScreen(token: widget.token, user: widget.user),
            ),
          );
          _refresh();
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.postNewLoad),
      ),
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
              return Center(child: Text(l10n.noShipmentsYet));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final listing = listings[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ShipmentDetailScreen(
                          token: widget.token,
                          user: widget.user,
                          listing: listing,
                        ),
                      ),
                    );
                    _refresh();
                  },
                  child: _ShipmentCard(
                    listing: listing,
                    isBusy: _busyIds.contains(listing.id),
                    onCancel: () => _cancel(listing),
                    onRateDriver: () => _rateDriver(listing),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final CargoListingModel listing;
  final bool isBusy;
  final VoidCallback onCancel;
  final VoidCallback onRateDriver;

  const _ShipmentCard({
    required this.listing,
    required this.isBusy,
    required this.onCancel,
    required this.onRateDriver,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isOpen = listing.status == CargoListingStatus.open;
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
          if (listing.driver != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_shipping_outlined, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${listing.driver!.fullName ?? l10n.driverFallback} · ${listing.driver!.phone ?? ''}'
                    '${listing.driver!.ratingAvg != null ? ' · ★${listing.driver!.ratingAvg!.toStringAsFixed(1)}' : ''}',
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (isOpen) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: isBusy ? null : onCancel,
              child: Text(l10n.cancelShipment),
            ),
          ],
          if (isCompleted) ...[
            const SizedBox(height: AppSpacing.sm),
            if (listing.myRating != null)
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    l10n.ratedDriverStars(listing.myRating!.stars),
                    style: textTheme.bodySmall,
                  ),
                ],
              )
            else
              PrimaryButton(
                label: l10n.rateDriverButton,
                isLoading: isBusy,
                onPressed: onRateDriver,
              ),
          ],
        ],
      ),
    );
  }
}
