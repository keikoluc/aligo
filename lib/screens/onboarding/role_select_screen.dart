import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import 'profile_form_screen.dart';

/// First onboarding step after a new account is verified: the user
/// declares which side of the marketplace they're on, which determines
/// what [ProfileFormScreen] asks for next.
class RoleSelectScreen extends StatelessWidget {
  final String token;
  final UserModel user;

  const RoleSelectScreen({super.key, required this.token, required this.user});

  void _selectRole(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProfileFormScreen(token: token, user: user, role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.roleSelectTitle, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(l10n.roleSelectSubtitle, style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              _RoleCard(
                icon: Icons.local_shipping_outlined,
                title: l10n.driverRoleTitle,
                subtitle: l10n.driverRoleSubtitle,
                onTap: () => _selectRole(context, UserRole.driver),
              ),
              const SizedBox(height: AppSpacing.md),
              _RoleCard(
                icon: Icons.inventory_2_outlined,
                title: l10n.shipperRoleTitle,
                subtitle: l10n.shipperRoleSubtitle,
                onTap: () => _selectRole(context, UserRole.shipper),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slateLight : AppColors.offWhite,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: scheme.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: AppColors.slate, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
