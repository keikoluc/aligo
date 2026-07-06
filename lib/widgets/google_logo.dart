import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The Google "G" mark, drawn to match the brand's four-color ring since
/// Material's [Icons.g_mobiledata] is a mobile-data glyph, not a logo.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const Color _blue = Color(0xFF4285F4);
  static const Color _green = Color(0xFF34A853);
  static const Color _yellow = Color(0xFFFBBC05);
  static const Color _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double strokeWidth = size.shortestSide * 0.22;
    final double radius = size.shortestSide / 2 - strokeWidth / 2;
    final Rect ringRect = Rect.fromCircle(center: center, radius: radius);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const double gapDeg = 2.5;
    const double mouthDeg = 72.5;
    const double segmentDeg = (360 - mouthDeg - gapDeg * 3) / 4;

    double startDeg = mouthDeg / 2;
    for (final Color color in [_green, _yellow, _red, _blue]) {
      canvas.drawArc(
        ringRect,
        _toRad(startDeg),
        _toRad(segmentDeg),
        false,
        ring..color = color,
      );
      startDeg += segmentDeg + gapDeg;
    }

    final Paint bar = Paint()
      ..color = _blue
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(center, Offset(center.dx + radius, center.dy), bar);
  }

  double _toRad(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}
