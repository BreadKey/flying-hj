import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/field.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/flyers/hyeonjung.dart';
import 'package:flying_hj/game/game_object.dart';

extension on double {
  int toInterval() => this * 10 ~/ 1;
}

class FlyingGame extends ChangeNotifier {
  static const int fps = 32;

  static const double gravity = -10;
  static const double flyPower = 10;
  static const int gameHeight = 15;
  static const double defaultVelocityX = 12;
  static const double defaultPathHieght = 7.5;
  static const double maxVelocityX = 40;
  static const double minPathHeight = 5.5;
  double _velocityY = 0;
  double _velocityX = 10;

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

  double _pathHeight;

  int _currentFrame = 0;

  void startGame() {
    isGameOver = false;
    _currentFrame = 0;

    _currentField = Field(1000, []);

    _previousBottomSlopeHeight = null;
    _previousTopSlopeHeight = null;

    _pathHeight = defaultPathHieght;

    fields.clear();
    fields.add(_currentField);

    final firstFallTime = 0.5;

    _pathStartPoint = Offset(
        0, gameHeight / 2 + (-gravity * firstFallTime * firstFallTime) / 2);

    flyer.x = _pathStartPoint.dx;
    flyer.y = _pathStartPoint.dy;
    flyer.angle = 0;
    _velocityX = defaultVelocityX;
    _velocityY = 0;

    _pathStartVelocity = Offset(_velocityX, 0);

    isFlying = false;

    _hurdleQueue.clear();

    _wallQueue.clear();

    addNextPath(firstFallTime, Offset(0, gravity));
    addStraightPath();
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
    final airTime = 1 / (Random().nextInt(4) + 1);

    if (_pathStartPoint.dy > gameHeight - _pathHeight / 2) {
      _pathStartVelocity = Offset(_velocityX, 0);
      return addNextPath(airTime, Offset(0, gravity / airTime));
    } else if (_pathStartPoint.dy < _pathHeight / 2) {
      _pathStartVelocity = Offset(_velocityX, 0);
      return addNextPath(airTime, Offset(0, flyPower / airTime));
    } else if (_pathStartVelocity.dy < 5 && _pathStartVelocity.dy > -5) {
      return addNextPath(airTime,
          Offset(0, (Random().nextInt(2) == 0 ? flyPower : gravity) / airTime));
    }

    final accelerationY =
        2 * (-_pathStartVelocity.dy * airTime) / airTime / airTime;

    final level = _velocityX / maxVelocityX;

    return addNextPath(airTime, Offset(0, accelerationY),
        offset: Offset(
            0,
            (_pathHeight / 2) /
                (level * maxVelocityX * airTime * 10) *
                (Random().nextInt(5) - 2)));
  }

  int addNextPath(double airTime, Offset acceleration,
      {Offset offset: Offset.zero}) {
    final parabola = generateParabola(
        _pathStartPoint, _pathStartVelocity, acceleration, airTime * _velocityX,
        offset: offset, interval: airTime.toInterval());
    _pathStartPoint = parabola.last;
    _pathStartVelocity += acceleration * airTime;

    final walls = generateWall(parabola..removeLast(), _pathHeight);
    return addWalls(walls);
  }

  int addStraightPath({double time: 2}) {
    final goalPoint = _pathStartPoint + Offset(_velocityX * time, 0);

    final wallParabola = generateParabola(
        _pathStartPoint,
        Offset(_velocityX, flyPower / 2),
        Offset(0, -flyPower / time),
        time * _velocityX,
        interval: time.toInterval())
      ..removeLast();

    final wallWidth = wallParabola[1].dx - wallParabola[0].dx;

    final walls = wallParabola.map((point) {
      final bottomSlopeHeight = point.dy - _pathHeight / 2;
      final topSlopeHeight = gameHeight -
          (_pathStartPoint.dy +
              _pathStartPoint.dy -
              point.dy +
              _pathHeight / 2);

      final generatedWalls = [
        Slope(wallWidth, bottomSlopeHeight,
            previousSlopeHeight: _previousBottomSlopeHeight,
            centerX: point.dx,
            fromTop: false),
        Slope(
          wallWidth,
          topSlopeHeight,
          previousSlopeHeight: _previousTopSlopeHeight,
          centerX: point.dx,
        ),
      ];

      _previousBottomSlopeHeight = bottomSlopeHeight;
      _previousTopSlopeHeight = topSlopeHeight;

      return generatedWalls;
    });

    _pathStartPoint = goalPoint;
    _pathStartVelocity = Offset(_velocityX, 0);

    return addWalls(walls);
  }

  int addWalls(Iterable<Iterable<GameObject>> walls) {
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

    if (flyer.top > (gameHeight + _pathHeight) || flyer.bottom < -_pathHeight) {
      gameOver();
    }

    final objects = <GameObject>[];

    if (_wallQueue.isNotEmpty) {
      objects.addAll(_wallQueue.first);

      if (_wallQueue.first.first.right < flyer.left) {
        _wallQueue.removeFirst();
      }
    }

    if (_hurdleQueue.isNotEmpty) {
      objects.add(_hurdleQueue.first);

      if (_hurdleQueue.first.right < flyer.left) {
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

    final wallIndexInMiddle = _currentField.walls.length ~/ 2;

    if (flyer.left > _currentField.walls[wallIndexInMiddle].first.right) {
      final newWallsLength = addNextPathByRandom();
      _currentField.walls.removeRange(0, newWallsLength);
    }

    _currentFrame++;

    if (_currentFrame % (fps * 5) == 0) {
      _velocityX += 1;
      _pathHeight -= 0.05;

      _velocityX = min(maxVelocityX, _velocityX);
      _pathHeight = max(minPathHeight, _pathHeight);
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

    if (_velocityY > 0 && !isFlying) {
      acceleration += gravity;
    } else if (_velocityY < 0 && isFlying) {
      acceleration += flyPower;
    }

    acceleration *= timeDelta;

    _velocityY += acceleration;

    flyer.x += _velocityX * timeDelta;
    flyer.y += _velocityY * timeDelta;
    flyer.angle = -_velocityY / gameHeight * pi / 2;
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
      {int interval: 20, Offset offset: Offset.zero}) {
    final time = distance / startVelocity.dx;
    final delta = time / interval;

    final parabola = <Offset>[start];

    Offset currentPoint = start;
    Offset currentVelocity = startVelocity;

    for (int i = 0; i < interval; i++) {
      currentVelocity += acceleration * delta;
      currentPoint += currentVelocity * delta + offset;
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
            previousSlopeHeight: _previousTopSlopeHeight, centerX: point.dx),
        Slope(width, bottomSlopeHeight,
            previousSlopeHeight: _previousBottomSlopeHeight,
            fromTop: false,
            centerX: point.dx)
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
      {this.previousSlopeHeight, this.fromTop = true, double centerX})
      : super(width, height, width, height) {
    x = centerX + width / 2;
    y = fromTop ? FlyingGame.gameHeight - height / 2 : height / 2;
  }

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
    slopePath.lineTo(slope.width + 0.01, slope.height);
    slopePath.lineTo(slope.width + 0.01, 0);
    slopePath.close();

    canvas.drawPath(slopePath, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
