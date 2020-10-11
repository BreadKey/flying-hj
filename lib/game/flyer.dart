import 'package:flutter/material.dart';

abstract class Flyer {
  final double inGameSize;

  double x;
  double y;

  Flyer(this.inGameSize);

  void dispose();

  void start();
  void dead();
  void fly();
  void endFly();

  Image get image;
}
