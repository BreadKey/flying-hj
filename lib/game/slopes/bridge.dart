import 'package:flutter/material.dart';
import 'package:flying_hj/colors.dart';
import 'package:flying_hj/game/slope.dart';

class Bridge extends Slope {
  Bridge(double width, double height, {double centerX})
      : super(width, height, centerX: centerX, fromTop: false);

  @override
  Widget get sprite => const CustomPaint(
        painter: const _BridgePainter(),
      );
}

class _BridgePainter extends CustomPainter {
  const _BridgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width / 5;

    canvas.translate(0, strokeWidth);

    final paint = Paint()
      ..color = colorOuterSpace
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final bridgePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.width / 2)
      ..lineTo(0, size.width / 2)
      ..lineTo(0, 0)
      ..lineTo(size.width, size.width / 2)
      ..moveTo(0, size.width / 2)
      ..lineTo(size.width, 0);

    canvas.drawPath(bridgePath, paint);

    if (size.height > size.width * 4) {
      paint.style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromLTWH(0, size.width * 2, size.width + 0.1, size.height),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
