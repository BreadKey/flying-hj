import 'package:flutter/material.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/flying_game.dart';

class GameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  FlyingGame game;
  double flyerSize;

  double gameRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game = FlyingGame();

    gameRatio = MediaQuery.of(context).size.height / game.field.height;

    flyerSize = gameRatio * game.flyer.spriteSize;
    game.startGame();

    game.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.lightBlue,
        child: SizedBox(
            width: game.field.width * gameRatio,
            height: game.field.height * gameRatio,
            child: Stack(
              children: [
                Align(
                  key: ValueKey("field"),
                  alignment: Alignment.bottomLeft,
                  child: Transform.translate(
                      offset: Offset(
                          (-game.flyer.x + game.flyer.spriteSize / 2) *
                              gameRatio,
                          0),
                      child: Stack(alignment: Alignment.bottomLeft, children: [
                        Transform.translate(
                            key: ValueKey(game.flyer),
                            offset: center(game.flyer),
                            child: Transform.rotate(
                              angle: game.flyer.angle,
                              child: SizedBox(
                                  width: flyerSize,
                                  height: flyerSize,
                                  child: game.flyer.sprite),
                            )),
                        Stack(
                            alignment: Alignment.bottomLeft,
                            key: ValueKey("hurdles"),
                            children: game.field.hurdles
                                .map((hurdle) => Transform.translate(
                                      key: ValueKey(hurdle),
                                      offset: center(hurdle),
                                      child: SizedBox(
                                        width: hurdle.spriteSize * gameRatio,
                                        height: hurdle.spriteSize * gameRatio,
                                        child: hurdle.sprite,
                                      ),
                                    ))
                                .toList()),
                        Stack(
                            alignment: Alignment.bottomLeft,
                            key: ValueKey("walls"),
                            children: game.field.walls
                                .expand((element) => element)
                                .map((wall) => Transform.translate(
                                      key: ValueKey(wall),
                                      offset: center(wall),
                                      child: SizedBox(
                                        width: wall.spriteSize * gameRatio,
                                        height: wall.spriteSize * gameRatio,
                                        child: wall.sprite,
                                      ),
                                    ))
                                .toList()),
                      ])),
                ),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: MaterialButton(
                        color: Colors.pink,
                        onHighlightChanged: (value) {
                          if (value) {
                            game.startFly();
                          } else {
                            game.endFly();
                          }
                        },
                        onPressed: () {
                          if (game.isGameOver) {
                            game.startGame();
                          }
                        },
                      ),
                    ))
              ],
            )),
      );

  Offset center(Flyer flyer) =>
      Offset(
          (flyer.x - flyer.spriteSize / 2), -(flyer.y - flyer.spriteSize / 2)) *
      gameRatio;
}
