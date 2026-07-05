import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/cargo_listing_model.dart';

/// Small colored badge showing a cargo listing's lifecycle state.
class CargoStatusPill extends StatelessWidget {
  final CargoListingStatus status;

  const CargoStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final (Color color, String label) = switch (status) {
      CargoListingStatus.open => (AppColors.amberDark, l10n.statusOpen),
      CargoListingStatus.accepted => (AppColors.info, l10n.statusAccepted),
      CargoListingStatus.inTransit => (AppColors.violet, l10n.statusInTransit),
      CargoListingStatus.completed => (AppColors.success, l10n.statusCompleted),
      CargoListingStatus.cancelled => (AppColors.error, l10n.statusCancelled),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}
