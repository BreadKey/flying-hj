import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/field.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/flyers/hyeonjung.dart';
import 'package:flying_hj/game/game_object.dart';
import 'package:flying_hj/game/items/straight_block.dart';
import 'package:flying_hj/game/slope.dart';
import 'package:flying_hj/game/slopes/bridge.dart';
import 'package:flying_hj/game/slopes/building.dart';

import 'item.dart';

class FlyingGame extends ChangeNotifier {
  static const int fps = 32;

  static const double gravity = -13;
  static const double flyPower = 13;
  static const int gameHeight = 15;
  static const double defaultVelocityX = 12;
  static const double defaultPathHieght = 7.5;
  static const double maxVelocityX = 40;
  static const double minPathHeight = 5.5;
  static const double sameBuildingError = 0.5;

  bool isFlying = false;

  final timeDelta = 1 / fps;

  Flyer flyer = Hyeonjung();

  Timer _frameGenerator;

  bool isGameOver = false;

  final _hurdleQueue = Queue<GameObject>();
  final _wallQueue = Queue<List<GameObject>>();

  final Field field = Field();
  final _itemQueue = Queue<Item>();
  final _activatedItems = List<Item>();

  Offset _pathStartVelocity;
  Offset _pathStartPoint;

  double _previousTopSlopeHeight;
  double _previousBuildingHeight;

  double _pathHeight;

  int _currentFrame = 0;

  double _levelVelocityX;

  double _lastAirTime;

  void startGame() {
    isGameOver = false;
    _currentFrame = 0;

    _previousBuildingHeight = null;
    _previousTopSlopeHeight = null;

    _pathHeight = defaultPathHieght;

    final firstFallTime = 0.5;

    _pathStartPoint = Offset(
        0, gameHeight / 2 + (-gravity * firstFallTime * firstFallTime) / 2);

    flyer.setPoint(_pathStartPoint);
    flyer.angle = 0;
    flyer.velocityX = defaultVelocityX;
    _levelVelocityX = flyer.velocityX;
    flyer.velocityY = 0;

    _pathStartVelocity = Offset(flyer.velocityX, 0);

    isFlying = false;

    field.clear();

    _hurdleQueue.clear();

    _wallQueue.clear();

    _itemQueue.clear();
    _activatedItems.clear();

    _lastAirTime = 0;

    addNextPath(firstFallTime, Offset(0, gravity));

    addStraightPath(time: 3);
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

  @override
  void dispose() {
    _frameGenerator?.cancel();
    field.dispose();
    super.dispose();
  }

  void update() {
    double accelerationY = (isFlying ? flyPower : gravity);

    if (flyer.velocityY > 0 && !isFlying) {
      accelerationY += gravity;
    } else if (flyer.velocityY < 0 && isFlying) {
      accelerationY += flyPower;
    }

    flyer.accelerationY = accelerationY;

    if (_currentFrame % (fps * 5) == 0) {
      if (flyer.velocityX < _levelVelocityX) {
        flyer.velocityX = _levelVelocityX;
      }

      _levelVelocityX += 1;
      flyer.velocityX += 1;
      _pathHeight -= 0.05;

      flyer.velocityX = min(maxVelocityX, flyer.velocityX);
      _pathHeight = max(minPathHeight, _pathHeight);
    }

    _updateItems();
    _moveFlyer();
    _checkGameOver();
    _refreshWalls();
    _checkItem();

    _currentFrame++;

    notifyListeners();
  }

  int addNextPathByRandom() {
    final airTime = 1 / (Random().nextInt(4) + 1);

    if (_pathStartPoint.dy > gameHeight - _pathHeight / 2) {
      _pathStartVelocity = Offset(_levelVelocityX, 0);
      return addNextPath(airTime, Offset(0, gravity / airTime));
    } else if (_pathStartPoint.dy < _pathHeight / 2) {
      _pathStartVelocity = Offset(_levelVelocityX, 0);
      return addNextPath(airTime, Offset(0, flyPower / airTime));
    } else if (_pathStartVelocity.dy < 5 && _pathStartVelocity.dy > -5) {
      return addNextPath(airTime,
          Offset(0, (Random().nextInt(2) == 0 ? flyPower : gravity) / airTime));
    }

    if (Random().nextInt(16) == 0) {
      return addStraightPath(time: airTime * 3, smootherTime: _lastAirTime / 3);
    }

    final accelerationY =
        2 * (-_pathStartVelocity.dy * airTime) / airTime / airTime;

    final offsetY = ((_levelVelocityX / maxVelocityX / _lastAirTime) *
        maxVelocityX *
        airTime *
        10);

    _lastAirTime = airTime;

    return addNextPath(airTime, Offset(0, accelerationY),
        offset: Offset(
            0, (_pathHeight / 2) / (offsetY) * (Random().nextInt(5) - 2)));
  }

  int addNextPath(double airTime, Offset acceleration,
      {Offset offset: Offset.zero}) {
    final parabola = generateParabola(_pathStartPoint, _pathStartVelocity,
        acceleration, airTime * _levelVelocityX,
        offset: offset);
    _pathStartPoint = parabola.last;
    _pathStartVelocity += acceleration * airTime;

    final walls = generateWall(
        parabola..removeLast(), parabola.map((_) => _pathHeight / 2).toList());
    return addWalls(walls);
  }

  int addStraightPath({double time: 2, double smootherTime: 0}) {
    final int smootherPathLength = smootherTime == 0
        ? 0
        : addNextPath(0.5, Offset(0, -_pathStartVelocity.dy * 2));

    addItem(StraightBlock(
        time / 2, time / 2, _levelVelocityX * time - flyer.width * 2)
      ..setPoint(_pathStartPoint));
    final goalPoint = _pathStartPoint + Offset(_levelVelocityX * time, 0);

    final minHeight = _pathHeight + flyer.height * 2;

    final startVelocityY = minHeight / time;

    final wallParabola = generateParabola(
      _pathStartPoint,
      Offset(_levelVelocityX, startVelocityY),
      Offset(0, -2 * startVelocityY / time),
      time * _levelVelocityX,
    )..removeLast();

    final deltaX = (goalPoint.dx - _pathStartPoint.dx) / (wallParabola.length);

    final path = List.generate(wallParabola.length,
        (index) => _pathStartPoint + Offset(deltaX * index, 0));

    final halfPathHeight = max(_pathHeight / 2.5, _pathHeight / (6 / time));

    final walls = generateWall(
        path,
        wallParabola
            .map((point) => _pathStartPoint.dy - point.dy + halfPathHeight)
            .toList()
              ..add(halfPathHeight),
        bridgeDice: 5);

    _pathStartPoint = goalPoint;
    _pathStartVelocity = Offset(_levelVelocityX, 0);

    return addWalls(walls) + smootherPathLength;
  }

  int addWalls(Iterable<Iterable<GameObject>> walls) {
    field.addWalls(walls);
    _wallQueue.addAll(walls);

    return walls.length;
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

  void _updateItems() {
    _activatedItems.toList().forEach((item) {
      item.activeTime -= timeDelta;
      if (item.activeTime <= 0) {
        _activatedItems.remove(item);
        item.end(flyer);
      } else {
        item.update(flyer);
      }
    });
  }

  void _moveFlyer() {
    flyer.velocityY += flyer.accelerationY * timeDelta;

    flyer.x += flyer.velocityX * timeDelta;
    flyer.y += flyer.velocityY * timeDelta;
    flyer.angle = -flyer.velocityY / gameHeight * pi / 2;
  }

  void _checkGameOver() {
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
  }

  void _refreshWalls() {
    final wallIndexInQuarter = field.walls.length ~/ 8;

    if (flyer.left > field.walls[wallIndexInQuarter].first.right) {
      addNextPathByRandom();
      field.walls.removeRange(0, wallIndexInQuarter);
    }
  }

  void _checkItem() {
    if (_itemQueue.isEmpty) return;
    final firstItem = _itemQueue.first;
    if (isCollided(flyer, firstItem)) {
      consumeItem(firstItem);
    } else if (flyer.left > firstItem.right) {
      removeItem(firstItem);
    }
  }

  void startFly() {
    isFlying = true;
    flyer.fly();
  }

  void endFly() {
    isFlying = false;
    flyer.endFly();
  }

  void consumeItem(Item item) {
    item.active(flyer);
    _activatedItems.add(item);
    removeItem(item);
  }

  List<Offset> generateParabola(
      Offset start, Offset startVelocity, Offset acceleration, double distance,
      {double unitX: 1.5, Offset offset: Offset.zero}) {
    final interval = distance ~/ unitX;
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
      List<Offset> path, List<double> pathHeights,
      {int bridgeDice = 2}) {
    assert(path.length >= 2);

    final width = path[1].dx - path[0].dx;

    bool isBridge;
    bool previousWasBridge = false;
    double bridgeStartY;

    final walls = <List<GameObject>>[];

    for (int index = 0; index < path.length; index++) {
      final point = path[index];

      final buildingHeight =
          calculateBuildingHeight(point.dy, pathHeights[index]);

      final topSlopeHeight =
          max(0.0, gameHeight - (point.dy + pathHeights[index]));

      if (previousWasBridge) {
        previousWasBridge = false;
      }

      if (buildingHeight == _previousBuildingHeight) {
        if (isBridge == null) {
          isBridge = canBeBridge(
                  walls,
                  List.generate(path.length,
                      (index) => path[index].dy - pathHeights[index]),
                  index) &&
              Random().nextInt(bridgeDice) == 0;
          if (isBridge) {
            bridgeStartY = point.dy - pathHeights[index];
          } else {
            isBridge = null;
          }
        } else if (isBridge) {
          if (index == path.length - 1) {
            isBridge = false;
          } else if (index < path.length - 2) {
            if (path[index + 1].dy -
                    pathHeights[index + 1] +
                    sameBuildingError <
                bridgeStartY) isBridge = false;
          }
        }
      } else {
        if (isBridge == true) {
          isBridge = false;
          isBridge = null;
          previousWasBridge = true;
        }
      }

      final generatedWalls = [
        Slope(
          width,
          topSlopeHeight,
          previousSlopeHeight: _previousTopSlopeHeight,
          centerX: point.dx,
        ),
        isBridge == true
            ? Bridge(width, buildingHeight, centerX: point.dx)
            : Building(width, buildingHeight,
                previousBuildingHeight: _previousBuildingHeight,
                canHasLightingLoad: !previousWasBridge,
                centerX: point.dx),
      ];

      _previousBuildingHeight = buildingHeight;
      _previousTopSlopeHeight = topSlopeHeight;

      walls.add(generatedWalls);
    }

    return walls;
  }

  bool canBeBridge(Iterable<List<GameObject>> walls,
          List<double> buildingHeights, index) =>
      index < buildingHeights.length - 2 &&
      buildingHeights[index + 1] > buildingHeights[index] &&
      walls.isNotEmpty &&
      !(walls.last.last as Building).hasLightingLoad;

  double calculateBuildingHeight(double y, double pathHeight) {
    final buildingHeight = max(0.0, y - pathHeight);

    if (buildingHeight != 0 &&
        _previousBuildingHeight != null &&
        (buildingHeight - _previousBuildingHeight).abs() < sameBuildingError) {
      return _previousBuildingHeight;
    }

    return buildingHeight;
  }

  void addItem(Item item) {
    field.addItem(item);
    _itemQueue.add(item);
  }

  void removeItem(Item item) {
    field.removeItem(item);
    _itemQueue.remove(item);
  }
}
