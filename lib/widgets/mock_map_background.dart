import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Stylized, dependency-free map surface used to mock the live tracking
/// canvas on the home screen without requiring a maps SDK or API key.
///
/// Optionally plots [driverPosition], a normalized (0..1) point within
/// the widget's bounds, as a small live-tracking dot on top of the
/// static illustration.
class MockMapBackground extends StatelessWidget {
  final Offset? driverPosition;

  const MockMapBackground({super.key, this.driverPosition});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF10192B) : const Color(0xFFE8EDF3),
      child: CustomPaint(
        size: Size.infinite,
        painter: _MapPainter(isDark: isDark, driverPosition: driverPosition),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final bool isDark;
  final Offset? driverPosition;

  _MapPainter({required this.isDark, this.driverPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final Color gridColor = (isDark ? Colors.white : AppColors.slate)
        .withValues(alpha: isDark ? 0.05 : 0.06);
    final Color roadColor = (isDark ? Colors.white : AppColors.slate)
        .withValues(alpha: isDark ? 0.10 : 0.10);

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    const double gridSpacing = 40;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Paint roadPaint = Paint()
      ..color = roadColor
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path road1 = Path()
      ..moveTo(-20, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.15,
        size.width * 0.55,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.6,
        size.width + 20,
        size.height * 0.5,
      );
    canvas.drawPath(road1, roadPaint);

    final Path road2 = Path()
      ..moveTo(size.width * 0.15, -20)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.4,
        size.width * 0.4,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.85,
        size.width * 0.5,
        size.height + 20,
      );
    canvas.drawPath(road2, roadPaint);

    final Paint routePaint = Paint()
      ..color = AppColors.amber.withValues(alpha: 0.85)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path activeRoute = Path()
      ..moveTo(size.width * 0.28, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.3,
        size.width * 0.62,
        size.height * 0.48,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.58,
        size.width * 0.68,
        size.height * 0.7,
      );
    canvas.drawPath(
      _dashPath(activeRoute, dashLength: 10, gapLength: 8),
      routePaint,
    );

    if (driverPosition != null) {
      final Offset center = Offset(
        driverPosition!.dx * size.width,
        driverPosition!.dy * size.height,
      );
      canvas.drawCircle(
        center,
        10,
        Paint()..color = AppColors.info.withValues(alpha: 0.25),
      );
      canvas.drawCircle(center, 6, Paint()..color = AppColors.info);
      canvas.drawCircle(
        center,
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  Path _dashPath(
    Path source, {
    required double dashLength,
    required double gapLength,
  }) {
    final Path dashed = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashLength : gapLength;
        final double next = (distance + length).clamp(0, metric.length);
        if (draw) {
          dashed.addPath(metric.extractPath(distance, next), Offset.zero);
        }
        distance = next;
        draw = !draw;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.driverPosition != driverPosition;
  }
}
