import 'package:flying_hj/game/game_object.dart';

abstract class Flyer extends GameObject {

  Flyer(double spriteWidth, double spriteHeight, double width, double height): super(spriteWidth, spriteHeight, width, height);

  void dispose();

  void start();
  void dead();
  void fly();
  void endFly();
}
