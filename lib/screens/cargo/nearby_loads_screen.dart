import 'package:flutter/material.dart';

import '../../core/cargo_categories.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/cargo_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cargo_listing_model.dart';
import '../../models/user_model.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/required_features_row.dart';

/// Driver flow: browse open cargo listings sorted nearest-first, and
/// accept one on a first-come basis.
class NearbyLoadsScreen extends StatefulWidget {
  final String token;
  final UserModel user;

  const NearbyLoadsScreen({
    super.key,
    required this.token,
    required this.user,
  });

  @override
  State<NearbyLoadsScreen> createState() => _NearbyLoadsScreenState();
}

class _NearbyLoadsScreenState extends State<NearbyLoadsScreen> {
  final _cargoApi = CargoApi();
  late Future<List<CargoListingModel>> _listingsFuture;
  final Set<String> _acceptingIds = {};

  @override
  void initState() {
    super.initState();
    _listingsFuture = _cargoApi.fetchNearby(widget.token);
  }

  void _refresh() {
    setState(() => _listingsFuture = _cargoApi.fetchNearby(widget.token));
  }

  Future<void> _accept(CargoListingModel listing, List<CargoListingModel> current) async {
    setState(() => _acceptingIds.add(listing.id));
    try {
      await _cargoApi.acceptListing(widget.token, listing.id);
      if (!mounted) return;
      setState(() {
        current.removeWhere((l) => l.id == listing.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loadAccepted)),
      );
    } on AlreadyTakenException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.alreadyTaken)),
      );
      _refresh();
    } on VehicleMismatchException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _acceptingIds.remove(listing.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nearbyLoadsTitle)),
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(message, textAlign: TextAlign.center),
                ),
              );
            }
            final listings = snapshot.data ?? [];
            if (listings.isEmpty) {
              return Center(child: Text(l10n.noOpenLoads));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final listing = listings[index];
                return _LoadCard(
                  listing: listing,
                  isAccepting: _acceptingIds.contains(listing.id),
                  onAccept: () => _accept(listing, listings),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LoadCard extends StatelessWidget {
  final CargoListingModel listing;
  final bool isAccepting;
  final VoidCallback onAccept;

  const _LoadCard({
    required this.listing,
    required this.isAccepting,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextTheme textTheme = Theme.of(context).textTheme;
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
              if (listing.distanceKm != null)
                Text(
                  l10n.kmAway(listing.distanceKm!.toStringAsFixed(1)),
                  style: textTheme.labelMedium?.copyWith(color: scheme.secondary),
                ),
            ],
          ),
          if (listing.description != null && listing.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(listing.description!, style: textTheme.bodySmall),
          ],
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
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: l10n.acceptButton,
            isLoading: isAccepting,
            onPressed: onAccept,
          ),
        ],
      ),
    );
  }
}
