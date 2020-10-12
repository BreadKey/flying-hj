import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/field.dart';
import 'package:flying_hj/game/fields/test_field.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/flyers/hyeonjung.dart';

class FlyingGame extends ChangeNotifier {
  static const int fps = 32;

  static const double gravity = -1;
  static const double flyPower = 2;
  double velocityY = 0;
  double velocityX = 25;

  bool isFlying = false;

  final timeDelta = 1 / fps;

  Field field = TestField();
  Flyer flyer = Hyeonjung();

  Timer _frameGenerator;

  bool isGameOver = false;

  final _hurdleQueue = Queue<Flyer>();
  final _wallQueue = Queue<List<Flyer>>();

  void startGame() {
    isGameOver = false;
    flyer.x = 0;
    flyer.y = field.height / 2;
    flyer.angle = 0;
    velocityY = 0;

    isFlying = false;

    _hurdleQueue.clear();
    _hurdleQueue.addAll(field.hurdles);

    _wallQueue.clear();
    _wallQueue.addAll(field.walls);

    _frameGenerator =
        Timer.periodic(const Duration(microseconds: 1000000 ~/ fps), (_) {
      update();
    });

    flyer.start();
  }

  @override
  void dispose() {
    _frameGenerator?.cancel();
    super.dispose();
  }

  void update() {
    _moveFlyer();

    notifyListeners();

    if (flyer.top > field.height || flyer.bottom < 0) {
      gameOver();
    }

    final objects = <Flyer>[];

    if (_wallQueue.isNotEmpty) {
      objects.addAll(_wallQueue.first);
    }

    if (_hurdleQueue.isNotEmpty) {
      objects.add(_hurdleQueue.first);
    }

    for (Flyer object in objects) {
      if (isCollided(flyer, object)) {
        gameOver();
        return;
      }
    }

    if (_wallQueue.first.first.right < flyer.left) {
      print("wall");
      _wallQueue.removeFirst();
    }

    if (_hurdleQueue.first.right < flyer.left) {
      print("hurdle");
      _hurdleQueue.removeFirst();
      print(_hurdleQueue.first.right);
    }

    if (_hurdleQueue.isEmpty && _wallQueue.isEmpty) {
      gameOver();
    }
  }

  bool isCollided(Flyer flyer, Flyer hurdle) {
    return flyer.right > hurdle.left &&
        flyer.left < hurdle.right &&
        flyer.top > hurdle.bottom &&
        flyer.bottom < hurdle.top;
  }

  void gameOver() {
    isGameOver = true;
    _frameGenerator.cancel();
    flyer.dead();
  }

  void _moveFlyer() {
    double acceleration;
    if (velocityY > 0 && !isFlying) {
      acceleration = timeDelta * (gravity - flyPower / 2) * fps;
    } else if (velocityY < 0 && isFlying) {
      acceleration = timeDelta * (-gravity / 2 + flyPower) * fps;
    } else {
      acceleration = timeDelta * (gravity + (isFlying ? flyPower : 0)) * fps;
    }

    velocityY += acceleration;

    flyer.x += velocityX * timeDelta;
    flyer.y += velocityY * timeDelta;
    flyer.angle = -velocityY / field.height * pi / 2;
  }

  void startFly() {
    isFlying = true;
    flyer.fly();
  }

  void endFly() {
    isFlying = false;
    flyer.endFly();
  }
}
