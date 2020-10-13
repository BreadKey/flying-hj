import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/field.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/flyers/hyeonjung.dart';
import 'package:flying_hj/game/game_object.dart';

class FlyingGame extends ChangeNotifier {
  static const int fps = 32;

  static const double gravity = -40;
  static const double flyPower = 40;
  static const int gameHeight = 100;
  double velocityY = 0;
  double velocityX = 80;

  bool isFlying = false;

  final timeDelta = 1 / fps;

  Flyer flyer = Hyeonjung();

  Timer _frameGenerator;

  bool isGameOver = false;

  final _hurdleQueue = Queue<GameObject>();
  final _wallQueue = Queue<List<GameObject>>();

  final fields = <Field>[];
  Field _currentField;

  Offset _pathStartVelocity;
  Offset _pathStartPoint;

  void startGame() {
    isGameOver = false;

    _pathStartVelocity = Offset(velocityX, 0);
    _pathStartPoint = Offset(0, gameHeight / 2);

    _currentField = Field(1000, []);

    addNextPath(1, Offset(0, gravity));
    addNextPath(1, Offset(0, flyPower * 2));
    addNextPath(0.75, Offset(0, gravity * 2));
    addNextPath(1, Offset(0, flyPower * 2));
    addNextPath(0.75, Offset(0, gravity * 3));
    addNextPath(1, Offset(0, flyPower));
    addNextPath(1, Offset(0, gravity));
    addNextPath(1, Offset(0, flyPower / 2));
    addNextPath(0.75, Offset(0, flyPower));
    addNextPath(1, Offset(0, 0));
    addNextPath(0.25, Offset(0, flyPower));
    addNextPath(1.25, Offset(0, gravity * 2));
    addNextPath(0.5, Offset(0, flyPower * 4));
    addNextPath(1, Offset(0, flyPower));
    addNextPath(1, Offset(0, gravity));
    addNextPath(0.5, Offset(0, gravity * 3));

    fields.clear();
    fields.add(_currentField);

    flyer.x = 0;
    flyer.y = gameHeight / 2;
    flyer.angle = 0;
    velocityY = 0;

    isFlying = false;

    _hurdleQueue.clear();

    _wallQueue.clear();
    _wallQueue.addAll(_currentField.walls);

    _frameGenerator =
        Timer.periodic(const Duration(microseconds: 1000000 ~/ fps), (_) {
      try {
        update();
      } catch (e) {
        print(e);
      }
    });

    flyer.start();
  }

  void addNextPath(double airTime, Offset acceleration) {
    _currentField.walls.addAll(generateWall(
        generteParabola(_pathStartPoint, _pathStartVelocity, acceleration,
            airTime * velocityX,
            interval: airTime * 10 ~/ 1),
        flyer.height * 6));

    _pathStartPoint +=
        _pathStartVelocity * airTime + acceleration * airTime * airTime / 2;
    _pathStartVelocity += acceleration * airTime;
  }

  @override
  void dispose() {
    _frameGenerator?.cancel();
    super.dispose();
  }

  void update() {
    _moveFlyer();

    if (flyer.top > gameHeight || flyer.bottom < 0) {
      gameOver();
    }

    final objects = <GameObject>[];

    if (_wallQueue.isNotEmpty) {
      objects.addAll(_wallQueue.first);

      if (_wallQueue.first.first.right < flyer.left) {
        print("wall");
        _wallQueue.removeFirst();
      }
    }

    if (_hurdleQueue.isNotEmpty) {
      objects.add(_hurdleQueue.first);

      if (_hurdleQueue.first.right < flyer.left) {
        print("hurdle");
        _hurdleQueue.removeFirst();
        print(_hurdleQueue.first.right);
      }
    }

    for (GameObject object in objects) {
      if (isCollided(flyer, object)) {
        gameOver();
        return;
      }
    }

    if (_hurdleQueue.isEmpty && _wallQueue.isEmpty) {
      gameOver();
    }

    notifyListeners();
  }

  bool isCollided(GameObject a, GameObject b) {
    return a.right > b.left &&
        a.left < b.right &&
        a.top > b.bottom &&
        a.bottom < b.top;
  }

  void gameOver() {
    isGameOver = true;
    _frameGenerator.cancel();
    flyer.dead();
  }

  void _moveFlyer() {
    double acceleration = (isFlying ? flyPower : gravity);

    if (velocityY > 0 && !isFlying) {
      acceleration += gravity;
    } else if (velocityY < 0 && isFlying) {
      acceleration += flyPower;
    }

    acceleration *= timeDelta;

    velocityY += acceleration;

    flyer.x += velocityX * timeDelta;
    flyer.y += velocityY * timeDelta;
    flyer.angle = -velocityY / gameHeight * pi / 2;
  }

  void startFly() {
    isFlying = true;
    flyer.fly();
  }

  void endFly() {
    isFlying = false;
    flyer.endFly();
  }

  List<Offset> generteParabola(
      Offset start, Offset startVelocity, Offset acceleration, double distance,
      {int interval: 20}) {
    final time = distance / startVelocity.dx;
    final delta = time / interval;

    final parabola = <Offset>[start];

    Offset currentPoint = start;
    Offset currentVelocity = startVelocity;

    for (int i = 0; i < interval - 1; i++) {
      currentVelocity += acceleration * delta;
      currentPoint += currentVelocity * delta;
      parabola.add(currentPoint);
    }

    parabola.add(start + startVelocity * time + acceleration * time * time / 2);

    return parabola;
  }

  List<List<GameObject>> generateWall(List<Offset> path, double pathHeight) {
    assert(path.length >= 2);

    final width = path[1].dx - path[0].dx;

    return path.map((point) {
      final bottomSlopeHeight = point.dy - pathHeight / 2;
      final topSlopeHeight = gameHeight - (point.dy + pathHeight / 2);
      return [
        Slope(width, topSlopeHeight)
          ..x = point.dx + width / 2 + 2
          ..y = gameHeight - topSlopeHeight / 2,
        Slope(width, bottomSlopeHeight)
          ..x = point.dx + width / 2 + 2
          ..y = bottomSlopeHeight / 2,
      ];
    }).toList();
  }
}

class Slope extends GameObject {
  final double angle;

  Slope(double width, double height, {this.angle = 0})
      : super(width, height, width, height);

  @override
  Widget get sprite => Container(
        color: Colors.white,
      );
}
