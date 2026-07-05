import 'package:flutter/material.dart';

import '../../core/cargo_categories.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/cargo_api.dart';
import '../../core/network/geocoding_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cargo_listing_model.dart';
import '../../models/driver_vehicle_model.dart';
import '../../models/user_model.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'my_shipments_screen.dart';

/// Shipper flow: post a cargo listing with pickup/dropoff and a price,
/// which drivers will then see sorted by distance in [NearbyLoadsScreen].
/// When [existingListing] is passed, the form pre-fills from it and submits
/// via `updateListing` instead of `createListing` (only possible while the
/// listing is still open — the backend re-enforces this either way).
class PostListingScreen extends StatefulWidget {
  final String token;
  final UserModel user;
  final CargoListingModel? existingListing;

  const PostListingScreen({
    super.key,
    required this.token,
    required this.user,
    this.existingListing,
  });

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

/// Per-feature surcharges the backend adds on top of the distance-based
/// price (see `pricingService.FEATURE_SURCHARGES`) — shown here so the
/// shipper knows why checking a box raises the suggested price.
const Map<VehicleAmenity, int> _featureSurcharges = {
  VehicleAmenity.refrigerated: 15000,
  VehicleAmenity.sideRearTent: 8000,
  VehicleAmenity.lift: 10000,
  VehicleAmenity.tieDownStraps: 5000,
};

class _PostListingScreenState extends State<PostListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final _cargoApi = CargoApi();
  String? _cargoType;
  GeoPoint? _pickup;
  GeoPoint? _dropoff;
  final Set<VehicleAmenity> _requiredFeatures = {};
  bool _isSubmitting = false;

  PriceEstimate? _priceEstimate;
  bool _isEstimating = false;
  bool _priceManuallyEdited = false;
  bool _isSettingPriceProgrammatically = false;

  bool get _isEditing => widget.existingListing != null;

  @override
  void initState() {
    super.initState();
    final CargoListingModel? existing = widget.existingListing;
    if (existing != null) {
      _cargoType = existing.cargoType;
      _descriptionController.text = existing.description ?? '';
      _pickup = existing.pickup;
      _dropoff = existing.dropoff;
      _requiredFeatures.addAll(existing.requiredFeatures.features);
      _priceManuallyEdited = true;
      _priceController.text = existing.price.round().toString();
    }
    _priceController.addListener(() {
      if (!_isSettingPriceProgrammatically) _priceManuallyEdited = true;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    final double? price = double.tryParse(value?.trim() ?? '');
    if (price == null || price <= 0) {
      return AppLocalizations.of(context)!.enterValidPrice;
    }
    return null;
  }

  Future<void> _updateEstimate() async {
    if (_cargoType == null || _pickup == null || _dropoff == null) return;

    setState(() => _isEstimating = true);
    try {
      final estimate = await _cargoApi.estimatePrice(
        token: widget.token,
        cargoType: _cargoType!,
        pickup: _pickup!,
        dropoff: _dropoff!,
        requiredFeatures: RequiredFeatures(features: _requiredFeatures),
      );
      if (!mounted) return;
      setState(() {
        _priceEstimate = estimate;
        if (!_priceManuallyEdited) {
          _isSettingPriceProgrammatically = true;
          _priceController.text = estimate.suggestedPrice.round().toString();
          _isSettingPriceProgrammatically = false;
        }
      });
    } on ApiException {
      // Non-fatal — the shipper can still enter a price manually.
    } finally {
      if (mounted) setState(() => _isEstimating = false);
    }
  }

  Future<void> _pickLocation({required bool isPickup}) async {
    final GeoPoint? result = await showModalBottomSheet<GeoPoint>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LocationPickerSheet(isPickup: isPickup),
    );
    if (result == null) return;
    setState(() {
      if (isPickup) {
        _pickup = result;
      } else {
        _dropoff = result;
      }
    });
    _updateEstimate();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (_pickup == null || _dropoff == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.choosePickupDropoff)));
      return;
    }
    if (_cargoType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chooseCargoType)));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final String? description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      final double price = double.parse(_priceController.text.trim());
      final RequiredFeatures requiredFeatures = RequiredFeatures(
        features: _requiredFeatures,
      );

      if (_isEditing) {
        final updated = await _cargoApi.updateListing(
          token: widget.token,
          listingId: widget.existingListing!.id,
          cargoType: _cargoType!,
          description: description,
          pickup: _pickup!,
          dropoff: _dropoff!,
          price: price,
          requiredFeatures: requiredFeatures,
        );
        if (!mounted) return;
        Navigator.of(context).pop(updated);
      } else {
        await _cargoApi.createListing(
          token: widget.token,
          cargoType: _cargoType!,
          description: description,
          pickup: _pickup!,
          dropoff: _dropoff!,
          price: price,
          requiredFeatures: requiredFeatures,
        );

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) =>
                MyShipmentsScreen(token: widget.token, user: widget.user),
          ),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editShipmentTitle : l10n.postShipmentTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.whatAreYouSending, style: textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.xl),
                DropdownButtonFormField<String>(
                  initialValue: _cargoType,
                  decoration: InputDecoration(
                    labelText: l10n.cargoTypeLabel,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                  ),
                  items: cargoCategoryOptions(l10n)
                      .map(
                        (c) => DropdownMenuItem(value: c.$1, child: Text(c.$2)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _cargoType = value);
                    _updateEstimate();
                  },
                  validator: (v) => v == null ? l10n.chooseCargoType : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _descriptionController,
                  label: l10n.descriptionOptional,
                  hint: l10n.descriptionHint,
                  prefixIcon: Icons.notes_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                _LocationField(
                  label: l10n.pickupLocationLabel,
                  point: _pickup,
                  icon: Icons.trip_origin,
                  onTap: () => _pickLocation(isPickup: true),
                ),
                const SizedBox(height: AppSpacing.md),
                _LocationField(
                  label: l10n.dropoffLocationLabel,
                  point: _dropoff,
                  icon: Icons.location_on_outlined,
                  onTap: () => _pickLocation(isPickup: false),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.specialRequirements, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                ..._featureSurcharges.entries.map(
                  (entry) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    value: _requiredFeatures.contains(entry.key),
                    title: Text(entry.key.label(l10n)),
                    subtitle: Text(
                      l10n.surchargeAmount('${entry.value}', l10n.currencyUzs),
                    ),
                    onChanged: (checked) {
                      setState(() {
                        if (checked ?? false) {
                          _requiredFeatures.add(entry.key);
                        } else {
                          _requiredFeatures.remove(entry.key);
                        }
                      });
                      _updateEstimate();
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _priceController,
                  label: l10n.priceLabel,
                  hint: l10n.priceHint,
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: _validatePrice,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_isEstimating)
                  Text(l10n.estimatingPrice)
                else if (_priceEstimate != null)
                  Text(
                    l10n.priceEstimateSummary(
                      _priceEstimate!.distanceKm.toStringAsFixed(1),
                      '${_priceEstimate!.suggestedPrice.round()}',
                      l10n.currencyUzs,
                    ),
                    style: textTheme.bodySmall,
                  ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: _isEditing
                      ? l10n.saveChangesButton
                      : l10n.postShipmentButton,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  final String label;
  final GeoPoint? point;
  final IconData icon;
  final VoidCallback onTap;

  const _LocationField({
    required this.label,
    required this.point,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: scheme.onSurfaceVariant),
            ),
            child: Text(
              point?.label ?? AppLocalizations.of(context)!.tapToSearchAddress,
              style: textTheme.bodyLarge?.copyWith(
                color: point == null ? scheme.onSurfaceVariant : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  final bool isPickup;

  const _LocationPickerSheet({required this.isPickup});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final _controller = TextEditingController();
  final _geocodingService = GeocodingService();
  List<GeocodingCandidate> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final String query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final results = await _geocodingService.search(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isPickup
                    ? AppLocalizations.of(context)!.pickupAddressTitle
                    : AppLocalizations.of(context)!.dropoffAddressTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.searchAddressHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    onPressed: _isSearching ? null : _search,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final candidate = _results[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(candidate.label),
                      onTap: () => Navigator.of(context).pop(
                        GeoPoint(
                          label: candidate.label,
                          lat: candidate.lat,
                          lng: candidate.lng,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
