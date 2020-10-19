import 'package:flutter/material.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/flying_game.dart';
import 'package:flying_hj/game/game_object.dart';

class GameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  FlyingGame game;

  double gameRatio = 1;

  @override
  void initState() {
    super.initState();
    game = FlyingGame();
    game.startGame();

    game.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    gameRatio = MediaQuery.of(context).size.height / FlyingGame.gameHeight;
  }

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          color: Colors.lightBlue,
          child: SizedBox(
              width: 10000,
              height: FlyingGame.gameHeight * gameRatio,
              child: Stack(
                children: [
                  Align(
                    key: ValueKey("field"),
                    alignment: Alignment.bottomLeft,
                    child: Transform.translate(
                        offset: Offset(
                            (-game.flyer.x + game.flyer.spriteWidth / 2) *
                                gameRatio,
                            0),
                        child:
                            Stack(alignment: Alignment.bottomLeft, children: [
                          Stack(
                              children: game.fields
                                  .map((field) => SizedBox(
                                        key: ValueKey(field),
                                        width: field.width * gameRatio,
                                        child: Stack(
                                          alignment: Alignment.bottomLeft,
                                          children: field.walls
                                              .expand((e) => e)
                                              .map(
                                                  (wall) => Transform.translate(
                                                        key: ValueKey(wall),
                                                        offset: center(wall),
                                                        child: SizedBox(
                                                          width:
                                                              wall.spriteWidth *
                                                                  gameRatio,
                                                          height:
                                                              wall.spriteHeight *
                                                                  gameRatio,
                                                          child: wall.sprite,
                                                        ),
                                                      ))
                                              .toList(),
                                        ),
                                      ))
                                  .toList()),
                          Transform.translate(
                              key: ValueKey(game.flyer),
                              offset: center(game.flyer),
                              child: Transform.rotate(
                                angle: game.flyer.angle,
                                child: SizedBox(
                                    width: game.flyer.spriteWidth * gameRatio,
                                    height: game.flyer.spriteHeight * gameRatio,
                                    child: game.flyer.sprite),
                              )),
                        ])),
                  ),
                ],
              )),
        ),
        floatingActionButton: MaterialButton(
          shape: CircleBorder(),
          minWidth: 80,
          height: 80,
          child: game.isGameOver
              ? const Icon(
                  Icons.refresh,
                  color: Colors.white,
                )
              : const Icon(Icons.flight_takeoff, color: Colors.white),
          color: Colors.pink,
          onPressed: () {},
          onHighlightChanged: (value) {
            if (value) {
              if (game.isGameOver) {
                game.startGame();
              } else {
                game.startFly();
              }
            } else {
              game.endFly();
            }
          },
        ),
      );

  Offset center(GameObject gameObject) =>
      Offset((gameObject.x - gameObject.spriteWidth / 2),
          -(gameObject.y - gameObject.spriteHeight / 2)) *
      gameRatio;
}
