import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/colors.dart';
import 'package:flying_hj/game/slope.dart';

class StarLoad extends Slope {
  double starSize;
  bool hasLight;
  final List<Offset> load = [Offset.zero];
  StarLoad(double width, double height,
      {double previousSlopeHeight, double centerX})
      : super(width, height,
            previousSlopeHeight: previousSlopeHeight,
            centerX: centerX,
            fromTop: true) {
    starSize = 0.6 / (Random().nextInt(6) + 1);
    hasLight = Random().nextInt(10) == 0;

    for (int _ = 0; _ < Random().nextInt(5) + 1; _++) {
      load.add(
          Offset((Random().nextInt(11) - 7) / 5, -15 / Random().nextInt(10)));
    }

    _sprite = CustomPaint(
      painter: _StarLoadPainter(this),
    );
  }

  Widget _sprite;

  @override
  Widget get sprite => _sprite;
}

class _StarLoadPainter extends CustomPainter {
  final StarLoad starLoad;

  final Path starPath;
  final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.1;

  _StarLoadPainter(this.starLoad)
      : starPath = Path()
          ..moveTo(0, 0)
          ..lineTo(starLoad.starSize, 0)
          ..moveTo(starLoad.starSize / 2, -starLoad.starSize / 2)
          ..lineTo(starLoad.starSize / 2, starLoad.starSize / 2);

  @override
  void paint(Canvas canvas, Size size) {
    if (starLoad.height == 0) return;

    final ratio = size.width / starLoad.width;

    canvas.scale(ratio);

    canvas.translate(starLoad.width, starLoad.height);

    starLoad.load.forEach((point) {
      canvas.save();
      canvas.translate(point.dx, point.dy);

      canvas.drawPath(
          starPath,
          _paint
            ..color = starLoad.hasLight ? colorSamoanSun : colorBlueBlizzard);
      canvas.restore();
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
