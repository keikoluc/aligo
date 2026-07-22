import 'package:flutter/material.dart';

import '../../core/storage/theme_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

/// App-wide preferences: currently just appearance (light/dark/system).
/// Reached from the home drawer's "Settings" entry.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _themeStorage = ThemeStorage();
  ThemeMode _selected = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadStoredThemeMode();
  }

  Future<void> _loadStoredThemeMode() async {
    String? stored;
    try {
      stored = await _themeStorage.readThemeMode();
    } catch (_) {
      stored = null;
    }
    if (!mounted || stored == null) return;
    final ThemeMode themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
    setState(() => _selected = themeMode);
  }

  Future<void> _select(ThemeMode themeMode) async {
    setState(() => _selected = themeMode);
    await _themeStorage.saveThemeMode(themeMode.name);
    if (!mounted) return;
    AligoApp.setThemeMode(context, themeMode);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n.appearanceSectionTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _ThemeOption(
            icon: Icons.brightness_auto_outlined,
            label: l10n.themeSystemLabel,
            selected: _selected == ThemeMode.system,
            onTap: () => _select(ThemeMode.system),
          ),
          const SizedBox(height: AppSpacing.md),
          _ThemeOption(
            icon: Icons.light_mode_outlined,
            label: l10n.themeLightLabel,
            selected: _selected == ThemeMode.light,
            onTap: () => _select(ThemeMode.light),
          ),
          const SizedBox(height: AppSpacing.md),
          _ThemeOption(
            icon: Icons.dark_mode_outlined,
            label: l10n.themeDarkLabel,
            selected: _selected == ThemeMode.dark,
            onTap: () => _select(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.amber.withValues(alpha: isDark ? 0.18 : 0.12)
              : (isDark ? AppColors.slateLight : AppColors.offWhite),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: selected ? AppColors.amber : scheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.onSurface),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.amber),
          ],
        ),
      ),
    );
  }
}
