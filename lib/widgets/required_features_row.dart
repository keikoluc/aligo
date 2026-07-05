import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/cargo_listing_model.dart';
import '../models/driver_vehicle_model.dart';

IconData _iconFor(VehicleAmenity amenity) {
  switch (amenity) {
    case VehicleAmenity.refrigerated:
      return Icons.ac_unit_rounded;
    case VehicleAmenity.sideRearTent:
      return Icons.door_sliding_outlined;
    case VehicleAmenity.lift:
      return Icons.arrow_circle_up_outlined;
    case VehicleAmenity.tieDownStraps:
      return Icons.link_rounded;
  }
}

/// Small icon row advertising which special vehicle capabilities a
/// listing requires — empty (renders nothing) when none are required.
class RequiredFeaturesRow extends StatelessWidget {
  final RequiredFeatures requiredFeatures;

  const RequiredFeaturesRow({super.key, required this.requiredFeatures});

  @override
  Widget build(BuildContext context) {
    if (requiredFeatures.isEmpty) return const SizedBox.shrink();

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: 4,
      children: requiredFeatures.features.map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(amenity), size: 13, color: scheme.secondary),
              const SizedBox(width: 4),
              Text(amenity.label(l10n), style: textTheme.labelSmall),
            ],
          ),
        );
      }).toList(),
    );
  }
}
