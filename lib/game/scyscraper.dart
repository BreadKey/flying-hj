import 'package:flying_hj/game/foundation/game_object.dart';

enum CrackPoint { top, center, bottom }

abstract class Skyscraper extends GameObject {
  final CrackPoint crackPoint;

  Skyscraper(
      double spriteWidth, double spriteHeight, double width, double height,
      {this.crackPoint = CrackPoint.center})
      : super(spriteWidth, spriteHeight, width, height);

  void collapse();
  void dispose();
}
