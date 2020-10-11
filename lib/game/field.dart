import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/flyer/hyeonjung.dart';

class Field extends ChangeNotifier {
  static const int fps = 32;
  final double screenWidth;
  final double screenHeight;

  static const double inGameHeight = 100;

  static const double gravity = 1;
  static const double flyPower = 2;
  double velocity = 0;

  bool isFlying = false;

  final double inGameRatio;

  final timeDelta = 1 / fps;

  Field(this.screenWidth, this.screenHeight)
      : this.inGameRatio = screenHeight / inGameHeight;

  Flyer flyer = Hyeonjung();

  Timer _frameGenerator;

  bool isGameOver = false;

  void startGame() {
    print("start Game");
    isGameOver = false;
    flyer.x = 0;
    flyer.y = screenHeight / 2;
    velocity = 0;

    isFlying = false;

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
    print("update");
    double acceleration;

    if (velocity < 0 && !isFlying) {
      acceleration = timeDelta * (gravity + flyPower / 2) * fps;
    } else if (velocity > 0 && isFlying) {
      acceleration = timeDelta * (-gravity / 2 - flyPower) * fps;
    } else {
      acceleration = timeDelta * (gravity - (isFlying ? flyPower : 0)) * fps;
    }

    acceleration *= screenHeight / inGameHeight;

    velocity += acceleration;

    flyer.y += velocity * timeDelta;
    notifyListeners();

    if (flyer.y > screenHeight || flyer.y < 0) {
      print("gameOver");
      isGameOver = true;
      _frameGenerator.cancel();
      flyer.dead();
    }
  }

  void startUp() {
    isFlying = true;
    flyer.fly();
  }

  void endUp() {
    isFlying = false;
    flyer.endFly();
  }
}
