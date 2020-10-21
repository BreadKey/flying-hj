import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/colors.dart';
import 'package:flying_hj/game/field.dart';
import 'package:flying_hj/game/flying_game.dart';
import 'package:flying_hj/game/moon.dart';
import 'package:flying_hj/screens/game_object_renderer.dart';
import 'package:provider/provider.dart';

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
          color: colorGalaxyBlue,
          child: SizedBox(
              width: 10000,
              height: FlyingGame.gameHeight * gameRatio,
              child: Stack(
                children: [
                  Align(
                      key: ValueKey("moon"),
                      alignment: Alignment.bottomLeft,
                      child: ChangeNotifierProvider.value(
                        value: game.moon,
                        child: Consumer<Moon>(
                          builder: (context, moon, _) => GameObjectRenderer(
                              key: ValueKey(moon),
                              gameObject: moon,
                              gameRatio: gameRatio),
                        ),
                      )),
                  Align(
                      key: ValueKey("field"),
                      alignment: Alignment.bottomLeft,
                      child: MultiProvider(
                        providers: [
                          ChangeNotifierProvider<FlyingGame>.value(value: game),
                          ChangeNotifierProvider<Field>.value(value: game.field)
                        ],
                        child: Consumer<FlyingGame>(
                          builder: (context, game, __) => Transform.translate(
                            offset: Offset(
                                (-game.flyer.x + game.flyer.spriteWidth / 2) *
                                    gameRatio,
                                0),
                            child: Stack(
                              alignment: Alignment.bottomLeft,
                              children: [
                                Consumer<Field>(
                                  builder: (_, field, ___) => SizedBox(
                                    key: ValueKey(field),
                                    width: double.infinity,
                                    child: Stack(
                                      alignment: Alignment.bottomLeft,
                                      children: field.walls
                                          .expand((e) => e)
                                          .map((wall) => GameObjectRenderer(
                                                gameObject: wall,
                                                gameRatio: gameRatio,
                                                key: ValueKey(wall),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                                Consumer<Field>(
                                  builder: (_, field, __) => Stack(
                                      alignment: Alignment.bottomLeft,
                                      children: field.items
                                          .map((item) => GameObjectRenderer(
                                                gameObject: item,
                                                gameRatio: gameRatio,
                                                key: ValueKey(item),
                                              ))
                                          .toList()),
                                ),
                                Consumer<FlyingGame>(
                                  builder: (context, _, __) =>
                                      GameObjectRenderer(
                                    gameObject: game.flyer,
                                    gameRatio: gameRatio,
                                    key: ValueKey(game.flyer),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))
                ],
              )),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: true,
          actions: [
            ChangeNotifierProvider.value(
              value: game,
              child: Consumer<FlyingGame>(
                builder: (context, game, child) {
                  return Text("${game.flyer.x.toStringAsFixed(2)}m",
                      style: Theme.of(context).textTheme.headline3);
                },
              ),
            )
          ],
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        floatingActionButton: MaterialButton(
          minWidth: 160,
          height: 80,
          child: Transform.rotate(
            angle: -pi / 2,
            child: const Icon(Icons.forward, color: Colors.white),
          ),
          color: Colors.black26,
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
}
