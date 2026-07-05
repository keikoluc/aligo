import '../l10n/app_localizations.dart';

/// Cargo categories the backend has per-km rates for (see the backend's
/// `pricingService.RATE_TABLE`) — keys are kept in sync manually since
/// there's no shared schema between the two. Listings store the key
/// (e.g. "general"), so every screen that displays `cargoType` needs to
/// map it back to a localized label via [cargoTypeLabel].
List<(String key, String label)> cargoCategoryOptions(AppLocalizations l10n) => [
  ('general', l10n.cargoGeneral),
  ('furniture', l10n.cargoFurniture),
  ('construction', l10n.cargoConstruction),
  ('perishable', l10n.cargoPerishable),
  ('equipment', l10n.cargoEquipment),
];

String cargoTypeLabel(String key, AppLocalizations l10n) {
  for (final option in cargoCategoryOptions(l10n)) {
    if (option.$1 == key) return option.$2;
  }
  return key;
}
