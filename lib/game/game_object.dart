import 'package:flutter/widgets.dart';

abstract class GameObject {
  final double spriteWidth;
  final double spriteHeight;
  final double width;
  final double height;

  GameObject(this.spriteWidth, this.spriteHeight, this.width, this.height);

  double get right => x + width / 2;
  double get left => x - width / 2;
  double get top => y + height / 2;
  double get bottom => y - height / 2;

  double x = 0;
  double y = 0;
  double angle = 0;

  Widget get sprite;

  void setPoint(Offset point) {
    x = point.dx;
    y = point.dy;
  }
}
