import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/vehicle_model.dart';
import 'primary_button.dart';
import 'vehicle_card.dart';

/// Modern draggable bottom sheet for quick vehicle selection, categorized
/// across Light Truck, Medium Freight and Heavy Van options.
class VehicleSelectionSheet extends StatefulWidget {
  final void Function(VehicleModel vehicle)? onConfirm;

  const VehicleSelectionSheet({super.key, this.onConfirm});

  @override
  State<VehicleSelectionSheet> createState() => _VehicleSelectionSheetState();
}

class _VehicleSelectionSheetState extends State<VehicleSelectionSheet> {
  VehicleCategory _selected = VehicleCategory.lightTruck;

  VehicleModel get _selectedVehicle => VehicleModel.catalog.firstWhere(
    (vehicle) => vehicle.category == _selected,
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.28,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.28, 0.42, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: scheme.outline,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Choose your vehicle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Icon(Icons.tune_rounded, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Pricing and availability update in real time',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              ...VehicleModel.catalog.map(
                (vehicle) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: VehicleCard(
                    vehicle: vehicle,
                    isSelected: _selected == vehicle.category,
                    onTap: () => setState(() => _selected = vehicle.category),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label:
                    'Book ${_selectedVehicle.name} · ${_selectedVehicle.formattedPrice}',
                onPressed: () => widget.onConfirm?.call(_selectedVehicle),
              ),
            ],
          ),
        );
      },
    );
  }
}
