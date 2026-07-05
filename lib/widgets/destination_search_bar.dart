import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Floating top search component prompting the user to set a cargo
/// destination, mirroring premium ride-hailing / logistics UX patterns.
class DestinationSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onMenuTap;
  final String hintText;

  const DestinationSearchBar({
    super.key,
    required this.onTap,
    required this.onMenuTap,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface = isDark ? AppColors.surfaceDark : AppColors.white;

    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.menu_rounded,
          onTap: onMenuTap,
          surface: surface,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Material(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.15),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        hintText,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 16,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color surface;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
