import 'package:flutter/foundation.dart';
import 'package:flying_hj/game/foundation/game_object.dart';

@deprecated
abstract class Skyscraper extends GameObject {
  final double crackPointY;

  Skyscraper(
      double spriteWidth, double spriteHeight, double width, double height,
      {@required this.crackPointY})
      : super(spriteWidth, spriteHeight, width, height);

  void collapse() {
    canCollide = false;
  }

  void dispose();
}
