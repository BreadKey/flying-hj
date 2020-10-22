import 'package:flutter/material.dart';
import 'package:flying_hj/game/flying_game.dart';
import 'package:flying_hj/game/game_object.dart';

class Wall extends GameObject {
  final double previousSlopeHeight;
  final bool fromTop;

  Wall(double width, double height,
      {this.previousSlopeHeight, this.fromTop = true, double centerX})
      : super(width, height, width, height) {
    x = centerX + width / 2;
    y = fromTop ? FlyingGame.gameHeight - height / 2 : height / 2;
  }

  @override
  Widget get sprite => CustomPaint(
        painter: DefaultWallPainter(this),
      );
}

class DefaultWallPainter extends CustomPainter {
  final Wall slope;

  DefaultWallPainter(this.slope);

  @override
  void paint(Canvas canvas, Size size) {
    final ratio = size.width / slope.width;

    canvas.scale(ratio);

    final slopePath = Path();

    slopePath.moveTo(
        0,
        !slope.fromTop
            ? slope.height - (slope.previousSlopeHeight ?? slope.height)
            : 0);
    slopePath.lineTo(
        0,
        slope.fromTop
            ? slope.previousSlopeHeight ?? slope.height
            : slope.height);
    slopePath.lineTo(slope.width + 0.01, slope.height);
    slopePath.lineTo(slope.width + 0.01, 0);
    slopePath.close();

    canvas.drawPath(slopePath, Paint()..color = Colors.blueGrey);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
