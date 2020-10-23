import 'package:flutter/material.dart';
import 'package:flying_hj/game/flying_game.dart';
import 'package:flying_hj/game/game_object.dart';

class Wall extends GameObject {
  final double previousWallHeight;
  final bool fromTop;

  Wall(double width, double height,
      {this.previousWallHeight, this.fromTop = true, double centerX})
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
  final Wall wall;

  DefaultWallPainter(this.wall);

  @override
  void paint(Canvas canvas, Size size) {
    final ratio = size.width / wall.width;

    canvas.scale(ratio);

    final wallPath = Path();

    wallPath.moveTo(
        0,
        !wall.fromTop
            ? wall.height - (wall.previousWallHeight ?? wall.height)
            : 0);
    wallPath.lineTo(
        0,
        wall.fromTop
            ? wall.previousWallHeight ?? wall.height
            : wall.height);
    wallPath.lineTo(wall.width + 0.01, wall.height);
    wallPath.lineTo(wall.width + 0.01, 0);
    wallPath.close();

    canvas.drawPath(wallPath, Paint()..color = Colors.blueGrey);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
