import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// The signature Aligo mark: a rounded slate container housing an amber
/// route glyph, used on the login screen and splash surfaces.
class AligoLogo extends StatelessWidget {
  final double size;

  const AligoLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.slate, AppColors.slateLight],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.local_shipping_rounded,
          color: AppColors.amber,
          size: size * 0.5,
        ),
      ),
    );
  }
}
