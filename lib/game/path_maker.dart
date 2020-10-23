import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/flying_game.dart';
import 'package:flying_hj/game/game_object.dart';
import 'package:flying_hj/game/walls/bridge.dart';
import 'package:flying_hj/game/walls/building.dart';
import 'package:flying_hj/game/walls/star_load.dart';

class PathMaker {
  static const double defaultPathHieght = 7.5;
  static const double minPathHeight = 5.5;
  static const double sameBuildingError = 0.5;

  Offset startPoint = Offset.zero;
  Offset startVelocity = Offset.zero;

  double _pathHeight;
  double get pathHeight => _pathHeight;
  set pathHeight(double value) {
    _pathHeight = max(minPathHeight, value);
  }

  double _previousTopWallHeight;
  double _previousBottomWallHeight;

  void reset() {
    _previousTopWallHeight = null;
    _previousBottomWallHeight = null;
    pathHeight = defaultPathHieght;
  }

  Iterable<List<GameObject>> generateParabolaPath(
      double airTime, Offset acceleration, double velocityX,
      {Offset offset: Offset.zero}) {
    final parabola = generateParabola(
        startPoint, startVelocity, acceleration, airTime * velocityX,
        offset: offset);

    startPoint = parabola.last;
    startVelocity += acceleration * airTime;

    return generateWall(
        parabola..removeLast(), parabola.map((_) => pathHeight / 2).toList());
  }

  Iterable<List<GameObject>> generateStraightPath(
      double time, double minHeight, double velocityX) {
    final startY = startPoint.dy;

    final goalPoint = startPoint + Offset(velocityX * time, 0);

    final startVelocityY = minHeight / time;

    final wallParabola = generateParabola(
      startPoint,
      Offset(velocityX, startVelocityY),
      Offset(0, -2 * startVelocityY / time),
      time * velocityX,
    )..removeLast();

    final deltaX = (goalPoint.dx - startPoint.dx) / (wallParabola.length);

    final path = List.generate(
        wallParabola.length, (index) => startPoint + Offset(deltaX * index, 0));

    final halfPathHeight = max(pathHeight / 2.5, pathHeight / (6 / time));

    startPoint = goalPoint;
    startVelocity = Offset(velocityX, 0);

    return generateWall(
      path,
      wallParabola.map((point) => startY - point.dy + halfPathHeight).toList()
        ..add(halfPathHeight),
    );
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
      {int bridgeDice = 5}) {
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

      final topWallHeight =
          max(0.0, FlyingGame.gameHeight - (point.dy + pathHeights[index]));

      if (previousWasBridge) {
        previousWasBridge = false;
      }

      if (buildingHeight == _previousBottomWallHeight) {
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
            previousWasBridge = true;
          } else if (index < path.length - 2) {
            if (path[index + 1].dy -
                    pathHeights[index + 1] +
                    sameBuildingError <
                bridgeStartY) isBridge = false;
            previousWasBridge = true;
          }
        }
      } else {
        if (isBridge == true) {
          isBridge = null;
          previousWasBridge = true;
        }
      }

      final generatedWalls = [
        StarLoad(
          width,
          topWallHeight,
          previousWallHeight: _previousTopWallHeight,
          centerX: point.dx,
        ),
        isBridge == true
            ? Bridge(width, buildingHeight, centerX: point.dx)
            : Building(width, buildingHeight,
                previousBuildingHeight: _previousBottomWallHeight,
                canHaveLightingLoad: !previousWasBridge,
                centerX: point.dx),
      ];

      _previousBottomWallHeight = buildingHeight;
      _previousTopWallHeight = topWallHeight;

      walls.add(generatedWalls);
    }

    return walls;
  }

  double calculateBuildingHeight(double y, double pathHeight) {
    final buildingHeight = max(0.0, y - pathHeight);

    if (buildingHeight != 0 &&
        _previousBottomWallHeight != null &&
        (buildingHeight - _previousBottomWallHeight).abs() < sameBuildingError) {
      return _previousBottomWallHeight;
    }

    return buildingHeight;
  }

  bool canBeBridge(Iterable<List<GameObject>> walls,
          List<double> buildingHeights, index) =>
      index < buildingHeights.length - 2 &&
      buildingHeights[index + 1] > buildingHeights[index] &&
      walls.isNotEmpty &&
      !(walls.last.last as Building).hasLightingLoad;
}
