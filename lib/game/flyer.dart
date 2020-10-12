import 'package:flutter/material.dart';

abstract class Flyer {
  final double spriteSize;
  final double width;
  final double height;

  double get right => x + width / 2;
  double get left => x - width / 2;
  double get top => y + height / 2;
  double get bottom => y - height / 2;

  double x;
  double y;
  double angle;

  Flyer(this.spriteSize, this.width, this.height);

  void dispose();

  void start();
  void dead();
  void fly();
  void endFly();

  Widget get sprite;
}
