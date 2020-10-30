import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/colors.dart';
import 'package:flying_hj/game/field.dart';
import 'package:flying_hj/game/flying_game.dart';
import 'package:flying_hj/game/moon.dart';
import 'package:flying_hj/screens/game_object_renderer.dart';
import 'package:provider/provider.dart';

import 'background_screen.dart';

class GameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  FlyingGame game;
  AnimationController _gameOverEffectController;
  Animation _gameOverEffect;

  StreamSubscription _gameOverSubscription;

  double gameRatio = 1;

  @override
  void initState() {
    super.initState();
    game = FlyingGame();
    game.startGame();
    _gameOverEffectController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _gameOverEffect = Tween(begin: Offset(0, 0), end: Offset(0.01, 0)).animate(
        CurvedAnimation(
            parent: _gameOverEffectController, curve: Curves.bounceInOut));

    _gameOverSubscription = game.gameOverStream.listen((gameOver) {
      if (gameOver) {
        _gameOverEffectController.forward();
      }
    });

    _gameOverEffectController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _gameOverEffectController.reverse();
      }
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
    _gameOverEffectController.dispose();
    _gameOverSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
            color: colorGalaxyBlue,
            child: Stack(
              children: [
                ChangeNotifierProvider.value(
                  value: game.moon,
                  child: Consumer<Moon>(
                      builder: (context, moon, _) => Stack(
                            children: [
                              Align(
                                  key: ValueKey("moon"),
                                  alignment: Alignment.topRight,
                                  child: GameObjectRenderer(
                                      key: ValueKey(moon),
                                      gameObject: moon,
                                      gameRatio: gameRatio)),
                            ],
                          )),
                ),
                SlideTransition(
                  position: _gameOverEffect,
                  child: Align(
                    key: ValueKey("game"),
                    alignment: Alignment.bottomLeft,
                    child: MultiProvider(
                      providers: [
                        ChangeNotifierProvider<FlyingGame>.value(value: game),
                        ChangeNotifierProvider<Field>.value(value: game.field)
                      ],
                      child: Consumer<FlyingGame>(
                          builder: (context, game, child) =>
                              Transform.translate(
                                offset: Offset(
                                    (-game.flyer.x +
                                            game.flyer.spriteWidth / 2) *
                                        gameRatio,
                                    0),
                                child: child,
                              ),
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              Provider<double>.value(
                                value: gameRatio,
                                child: const BackgroundScreen(),
                              ),
                              Consumer<Field>(
                                key: ValueKey("field"),
                                builder: (_, field, __) => Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: field.path
                                      .expand((e) => e)
                                      .map((wall) => GameObjectRenderer(
                                            gameObject: wall,
                                            gameRatio: gameRatio,
                                            key: ValueKey(wall),
                                          ))
                                      .toList()
                                        ..addAll(field.items
                                            .map((item) => GameObjectRenderer(
                                                  gameObject: item,
                                                  gameRatio: gameRatio,
                                                  key: ValueKey(item),
                                                ))
                                            .toList()),
                                ),
                              ),
                              Consumer<FlyingGame>(
                                key: ValueKey("flyer"),
                                builder: (context, _, __) => GameObjectRenderer(
                                  gameObject: game.flyer,
                                  gameRatio: gameRatio,
                                  key: ValueKey(game.flyer),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                )
              ],
            )),
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
          height: 100,
          child: Transform.rotate(
              angle: -pi / 6,
              child: Image.asset(
                "assets/hj/frame3.png",
                color: Colors.white,
                width: 60,
                filterQuality: FilterQuality.none,
                fit: BoxFit.contain,
              )),
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
