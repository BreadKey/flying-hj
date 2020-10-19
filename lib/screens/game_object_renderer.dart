import 'package:flutter/material.dart';
import 'package:flying_hj/game/game_object.dart';

class GameObjectRenderer extends StatelessWidget {
  final GameObject gameObject;
  final double gameRatio;
  final double screenWidth;
  final double screenHeight;

  GameObjectRenderer(
      {Key key, @required this.gameObject, @required this.gameRatio})
      : this.screenWidth = gameObject.spriteWidth * gameRatio,
        this.screenHeight = gameObject.spriteHeight * gameRatio,
        super(key: key);

  Offset get center =>
      Offset((gameObject.x - gameObject.spriteWidth / 2),
          -(gameObject.y - gameObject.spriteHeight / 2)) *
      gameRatio;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: center,
        child: Transform.rotate(
          angle: gameObject.angle,
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: gameObject.sprite,
          ),
        ));
  }
}
