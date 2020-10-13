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

  static const double gravity = -100;
  static const double flyPower = 100;
  static const int gameHeight = 100;
  double velocityY = 0;
  double velocityX = 150;

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

  double _previousTopSlopeHeight;
  double _previousBottomSlopeHeight;

  double _pathHieght;

  void startGame() {
    isGameOver = false;

    _pathStartVelocity = Offset(velocityX, 0);
    _pathStartPoint = Offset(0, gameHeight / 2);

    _currentField = Field(1000, []);

    _previousBottomSlopeHeight = null;
    _previousTopSlopeHeight = null;

    _pathHieght = flyer.height * 10;

    fields.clear();
    fields.add(_currentField);

    flyer.x = 0;
    flyer.y = gameHeight / 2;
    flyer.angle = 0;
    velocityY = 0;

    isFlying = false;

    _hurdleQueue.clear();

    _wallQueue.clear();

    addNextPath(0.5, Offset(0, gravity));
    for (int i = 0; i < 10; i++) {
      addNextPathByRandom();
    }

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

  int addNextPathByRandom() {
    final airTime = velocityX / flyPower / (Random().nextInt(4) + 1);

    final accelerationY = (velocityX /
                (_pathStartVelocity.dy < 0 ? flyPower : gravity) /
                2 *
                airTime -
            _pathStartVelocity.dy * airTime) *
        2 /
        (airTime * airTime);

    print(accelerationY);

    return addNextPath(airTime, Offset(0, accelerationY));
  }

  int addNextPath(double airTime, Offset acceleration) {
    final halfParabola = generateParabola(
        _pathStartPoint, _pathStartVelocity, acceleration, airTime * velocityX,
        interval: airTime * 10 ~/ 1);
    _pathStartPoint = halfParabola.last;
    _pathStartVelocity += acceleration * airTime;

    final walls = generateWall(halfParabola..removeLast(), _pathHieght);

    _currentField.walls.addAll(walls);

    _wallQueue.addAll(walls);

    return walls.length;
  }

  @override
  void dispose() {
    _frameGenerator?.cancel();
    super.dispose();
  }

  void update() {
    _moveFlyer();

    if (flyer.top > (gameHeight + _pathHieght) || flyer.bottom < -_pathHieght) {
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

    final maxWallLengthInPath = (velocityX / flyPower * 10).round();

    if (flyer.left >
        _currentField.walls[maxWallLengthInPath].first.right) {
      print(_currentField.walls[maxWallLengthInPath].first.right);
      final newWallsLength = addNextPathByRandom();
      _currentField.walls.removeRange(0, newWallsLength);
    }

    notifyListeners();
  }

  bool isCollided(GameObject a, GameObject b) {
    return b.height != 0 &&
        a.right > b.left &&
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

  List<Offset> generateParabola(
      Offset start, Offset startVelocity, Offset acceleration, double distance,
      {int interval: 20}) {
    final time = distance / startVelocity.dx;
    final delta = time / interval;

    final parabola = <Offset>[start];

    Offset currentPoint = start;
    Offset currentVelocity = startVelocity;

    for (int i = 0; i < interval; i++) {
      currentVelocity += acceleration * delta;
      currentPoint += currentVelocity * delta;
      parabola.add(currentPoint);
    }

    return parabola;
  }

  Iterable<List<GameObject>> generateWall(
      List<Offset> path, double pathHeight) {
    assert(path.length >= 2);

    final width = path[1].dx - path[0].dx;

    return path.map((point) {
      final bottomSlopeHeight = max(0.0, point.dy - pathHeight / 2);
      final topSlopeHeight = max(0.0, gameHeight - (point.dy + pathHeight / 2));
      final wall = [
        Slope(width, topSlopeHeight,
            previousSlopeHeight: _previousTopSlopeHeight)
          ..x = point.dx + width / 2
          ..y = gameHeight - topSlopeHeight / 2,
        Slope(width, bottomSlopeHeight,
            previousSlopeHeight: _previousBottomSlopeHeight, fromTop: false)
          ..x = point.dx + width / 2
          ..y = bottomSlopeHeight / 2,
      ];

      _previousTopSlopeHeight = topSlopeHeight;
      _previousBottomSlopeHeight = bottomSlopeHeight;

      return wall;
    });
  }
}

class Slope extends GameObject {
  final double previousSlopeHeight;
  final bool fromTop;

  Slope(double width, double height,
      {this.previousSlopeHeight, this.fromTop = true})
      : super(width, height, width, height);

  @override
  Widget get sprite => CustomPaint(
        painter: SlopePainter(this),
      );
}

class SlopePainter extends CustomPainter {
  final Slope slope;

  SlopePainter(this.slope);

  @override
  void paint(Canvas canvas, Size size) {
    final ratio = size.width / slope.width;

    canvas.scale(ratio);

    final slopePath = Path();

    slopePath.moveTo(
        0,
        !slope.fromTop
            ? slope.height - (slope.previousSlopeHeight ?? slope.height)
            : 0);
    slopePath.lineTo(
        0,
        slope.fromTop
            ? slope.previousSlopeHeight ?? slope.height
            : slope.height);
    slopePath.lineTo(slope.width, slope.height);
    slopePath.lineTo(slope.width, 0);
    slopePath.close();

    canvas.drawPath(slopePath, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
