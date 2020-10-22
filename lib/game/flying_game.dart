import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/field.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/flyers/hyeonjung.dart';
import 'package:flying_hj/game/game_object.dart';
import 'package:flying_hj/game/items/straight_block.dart';
import 'package:flying_hj/game/moon.dart';
import 'package:flying_hj/game/path_maker.dart';

import 'item.dart';

class FlyingGame extends ChangeNotifier {
  static const int maxFps = 100;

  static const double gravity = -13;
  static const double flyPower = 13;
  static const double gameHeight = 15;
  static const double defaultVelocityX = 12;
  static const double maxVelocityX = 40;

  bool isFlying = false;

  double timeDelta = 1 / maxFps;

  Flyer flyer = Hyeonjung();
  final PathMaker _pathMaker = PathMaker();

  Timer _frameGenerator;

  bool isGameOver = false;

  final _hurdleQueue = Queue<GameObject>();
  final _wallQueue = Queue<List<GameObject>>();

  final Field field = Field();
  final _itemQueue = Queue<Item>();
  final _activatedItems = List<Item>();

  double _levelVelocityX;

  double _lastAirTime;

  int lastTimeStamp;
  double accTime = 0;

  final Moon moon = Moon();

  void startGame() {
    isGameOver = false;
    _pathMaker.reset();

    final firstFallTime = 0.5;

    _levelVelocityX = defaultVelocityX;

    _pathMaker.startPoint = Offset(
        0, gameHeight / 2 + (-gravity * firstFallTime * firstFallTime) / 2);
    _pathMaker.startVelocity = Offset(_levelVelocityX, 0);

    flyer.setPoint(_pathMaker.startPoint);
    flyer.angle = 0;
    flyer.velocityX = _levelVelocityX;
    flyer.velocityY = 0;

    isFlying = false;

    field.clear();

    _hurdleQueue.clear();

    _wallQueue.clear();

    _itemQueue.clear();
    _activatedItems.clear();

    _lastAirTime = 0;

    accTime = 0;

    moon.setPoint(Offset(0, 0));

    addParabolaPath(firstFallTime, Offset(0, gravity));

    addStraightPath(time: 3);
    for (int i = 0; i < 10; i++) {
      addNextPathByRandom();
    }

    timeDelta = 1 / maxFps;
    lastTimeStamp = null;
    _frameGenerator =
        Timer.periodic(const Duration(microseconds: 1000000 ~/ maxFps), (_) {
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
    moon.dispose();
    super.dispose();
  }

  void update() {
    final currentTimeStamp = DateTime.now().millisecondsSinceEpoch;

    if (lastTimeStamp != null) {
      timeDelta = (currentTimeStamp - lastTimeStamp) / 1000;

      if (timeDelta > 1) {
        timeDelta = 1 / maxFps;
        lastTimeStamp = null;
        return;
      }
    }
    double accelerationY = (isFlying ? flyPower : gravity);

    if (flyer.velocityY > 0 && !isFlying) {
      accelerationY += gravity;
    } else if (flyer.velocityY < 0 && isFlying) {
      accelerationY += flyPower;
    }

    flyer.accelerationY = accelerationY;

    if (accTime > 5) {
      _levelUp();

      accTime -= 5;
    }

    _updateItems();
    _moveFlyer();
    _checkGameOver();
    _refreshWalls();
    _checkItem();

    accTime += timeDelta;

    notifyListeners();
    lastTimeStamp = currentTimeStamp;
  }

  void _levelUp() {
    if (flyer.velocityX < _levelVelocityX) {
      flyer.velocityX = _levelVelocityX;
    }

    _levelVelocityX += 1;
    flyer.velocityX += 1;
    _pathMaker.pathHeight -= 0.05;

    flyer.velocityX = min(maxVelocityX, flyer.velocityX);

    moon.setPoint(Offset(moon.x - 0.05, moon.y));
  }

  void addNextPathByRandom() {
    final airTime = 1 / (Random().nextInt(4) + 1);

    final startPoint = _pathMaker.startPoint;

    if (startPoint.dy > gameHeight - _pathMaker.pathHeight / 2) {
      _pathMaker.startVelocity = Offset(_levelVelocityX, 0);
      return addParabolaPath(airTime, Offset(0, gravity / airTime));
    } else if (startPoint.dy < _pathMaker.pathHeight / 2) {
      _pathMaker.startVelocity = Offset(_levelVelocityX, 0);
      return addParabolaPath(airTime, Offset(0, flyPower / airTime));
    } else if (_pathMaker.startVelocity.dy.abs() < 5) {
      return addParabolaPath(airTime,
          Offset(0, (Random().nextInt(2) == 0 ? flyPower : gravity) / airTime));
    }

    if (Random().nextInt(16) == 0) {
      return addStraightPath(time: airTime * 3, smoother: true);
    }

    final accelerationY =
        2 * (-_pathMaker.startVelocity.dy * airTime) / airTime / airTime;

    final offsetY = ((_levelVelocityX / maxVelocityX / _lastAirTime) *
        maxVelocityX *
        airTime *
        10);

    _lastAirTime = airTime;

    return addParabolaPath(airTime, Offset(0, accelerationY),
        offset: Offset(
            0,
            (_pathMaker.pathHeight / 2) /
                (offsetY) *
                (Random().nextInt(5) - 2)));
  }

  void addParabolaPath(double airTime, Offset acceleration,
      {Offset offset: Offset.zero}) {
    final walls =
        _pathMaker.generateParabolaPath(airTime, acceleration, _levelVelocityX);
    return addWalls(walls);
  }

  void addStraightPath({double time: 2, bool smoother: false}) {
    if (smoother) {
      addParabolaPath(0.5, Offset(0, -_pathMaker.startVelocity.dy * 2));
    }

    addItem(StraightBlock(
        time / 2, time / 2, _levelVelocityX * time - flyer.width * 2)
      ..setPoint(_pathMaker.startPoint));

    final walls = _pathMaker.generateStraightPath(
        time, _pathMaker.pathHeight + flyer.height * 2, _levelVelocityX);

    return addWalls(walls);
  }

  void addWalls(Iterable<Iterable<GameObject>> walls) {
    field.addWalls(walls);
    _wallQueue.addAll(walls);
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
    if (flyer.top > (gameHeight + _pathMaker.pathHeight) ||
        flyer.bottom < -_pathMaker.pathHeight) {
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
    final checkPointIndex = field.walls.length ~/ 8;

    if (flyer.left > field.walls[checkPointIndex].first.right) {
      addNextPathByRandom();
      field.walls.removeRange(0, checkPointIndex);
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

  void addItem(Item item) {
    field.addItem(item);
    _itemQueue.add(item);
  }

  void removeItem(Item item) {
    field.removeItem(item);
    _itemQueue.remove(item);
  }
}
