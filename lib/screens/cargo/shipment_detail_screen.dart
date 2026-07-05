import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
import 'track_delivery_screen.dart';

/// Shipper flow: full detail view of a single shipment, reached by tapping
/// a card in [MyShipmentsScreen]. Surfaces edit/cancel/track/rate actions
/// depending on the listing's current status.
class ShipmentDetailScreen extends StatefulWidget {
  final String token;
  final UserModel user;
  final CargoListingModel listing;

  const ShipmentDetailScreen({
    super.key,
    required this.token,
    required this.user,
    required this.listing,
  });

  @override
  State<ShipmentDetailScreen> createState() => _ShipmentDetailScreenState();
}

class _ShipmentDetailScreenState extends State<ShipmentDetailScreen> {
  final _cargoApi = CargoApi();
  late CargoListingModel _listing = widget.listing;
  bool _isBusy = false;

  Future<void> _edit() async {
    final result = await Navigator.of(context).push<CargoListingModel>(
      MaterialPageRoute<CargoListingModel>(
        builder: (_) => PostListingScreen(
          token: widget.token,
          user: widget.user,
          existingListing: _listing,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _listing = result;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.shipmentUpdated)),
    );
  }

  Future<void> _cancel() async {
    setState(() => _isBusy = true);
    try {
      final updated = await _cargoApi.cancelListing(widget.token, _listing.id);
      if (!mounted) return;
      setState(() {
        _listing = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.shipmentCancelled),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _rateDriver() async {
    final result = await showRatingDialog(
      context,
      title: AppLocalizations.of(context)!.rateDriverTitle,
    );
    if (result == null) return;
    final (stars, comment) = result;
    if (!mounted) return;

    setState(() => _isBusy = true);
    try {
      final updated = await _cargoApi.rateListing(
        widget.token,
        _listing.id,
        stars: stars,
        comment: comment,
      );
      if (!mounted) return;
      setState(() {
        _listing = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.thanksForRating)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _track() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            TrackDeliveryScreen(token: widget.token, listing: _listing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isOpen = _listing.status == CargoListingStatus.open;
    final bool isTrackable =
        _listing.status == CargoListingStatus.accepted ||
        _listing.status == CargoListingStatus.inTransit ||
        _listing.status == CargoListingStatus.completed;
    final bool isCompleted = _listing.status == CargoListingStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shipmentDetailsTitle),
        actions: [
          if (isOpen)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editButton,
              onPressed: _isBusy ? null : _edit,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cargoTypeLabel(_listing.cargoType, l10n),
                      style: textTheme.headlineSmall,
                    ),
                  ),
                  CargoStatusPill(status: _listing.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.postedOnLabel(
                  DateFormat.yMMMd().format(DateTime.parse(_listing.createdAt)),
                ),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _DetailSection(
                icon: Icons.trip_origin,
                label: l10n.pickupLocationLabel,
                value: _listing.pickup.label,
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailSection(
                icon: Icons.location_on_outlined,
                label: l10n.dropoffLocationLabel,
                value: _listing.dropoff.label,
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailSection(
                icon: Icons.notes_outlined,
                label: l10n.descriptionLabel,
                value: _listing.description?.trim().isNotEmpty == true
                    ? _listing.description!
                    : l10n.noDescriptionProvided,
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailSection(
                icon: Icons.payments_outlined,
                label: l10n.priceOnlyLabel,
                value:
                    '${_listing.price.toStringAsFixed(0)} ${l10n.currencyUzs}',
              ),
              if (!_listing.requiredFeatures.isEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.specialRequirements, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                RequiredFeaturesRow(
                  requiredFeatures: _listing.requiredFeatures,
                ),
              ],
              if (_listing.driver != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.slateLight
                        : AppColors.offWhite,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: scheme.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${_listing.driver!.fullName ?? l10n.driverFallback} · ${_listing.driver!.phone ?? ''}'
                          '${_listing.driver!.ratingAvg != null ? ' · ★${_listing.driver!.ratingAvg!.toStringAsFixed(1)}' : ''}',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (isOpen) ...[
                PrimaryButton(
                  label: l10n.editButton,
                  isLoading: false,
                  onPressed: _isBusy ? null : _edit,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: _isBusy ? null : _cancel,
                  child: Text(l10n.cancelShipment),
                ),
              ],
              if (isTrackable) ...[
                PrimaryButton(
                  label: l10n.trackShipmentButton,
                  isLoading: false,
                  onPressed: _track,
                ),
              ],
              if (isCompleted) ...[
                const SizedBox(height: AppSpacing.sm),
                if (_listing.myRating != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.ratedDriverStars(_listing.myRating!.stars),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  )
                else
                  PrimaryButton(
                    label: l10n.rateDriverButton,
                    isLoading: _isBusy,
                    onPressed: _rateDriver,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailSection({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
