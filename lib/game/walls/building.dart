import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flying_hj/colors.dart';
import 'package:flying_hj/game/wall.dart';

const double lightingLoadHeight = 1;

class Building extends Wall {
  final List<bool> lights = [];
  bool hasGuideLight;
  bool hasLightingLoad;

  Building(double width, double height,
      {double previousBuildingHeight,
      bool fromTop = false,
      double centerX,
      bool canHaveLightingLoad})
      : super(width, height,
            previousWallHeight: previousBuildingHeight,
            fromTop: fromTop,
            centerX: centerX) {
    hasGuideLight = previousBuildingHeight != 0 && Random().nextInt(10) == 0;
    final hasWindow = Random().nextInt(5) == 0;
    if (hasWindow) {
      int windowsCount = 2 * (Random().nextInt(3) + 1);

      for (int _ = 0; _ < windowsCount; _++) {
        lights.add(Random().nextBool());
      }
    }

    hasLightingLoad = canHaveLightingLoad && Random().nextInt(20) == 0;

    _sprite = Container(
      child: CustomPaint(
        painter: _BuildingPainter(this),
      ),
    );
  }

  Widget _sprite;
  @override
  Widget get sprite => _sprite;
}

class _BuildingPainter extends CustomPainter {
  static const windowStrokeWidth = 0.4;
  final Building building;
  final Rect buildingRect;

  final _paint = Paint();

  _BuildingPainter(this.building)
      : this.buildingRect = Rect.fromLTWH(
            0,
            building.hasLightingLoad ? lightingLoadHeight : 0,
            building.width + 0.01,
            building.height);

  @override
  void paint(Canvas canvas, Size size) {
    final ratio = size.width / building.width;

    canvas.scale(ratio);

    _paint.strokeWidth = windowStrokeWidth;
    _paint.color = colorOuterSpace;
    _paint.strokeCap = StrokeCap.butt;

    canvas.drawRect(buildingRect, _paint);

    for (int i = 0; i < building.lights.length; i++) {
      final column = i % 2;
      final row = i ~/ 2;
      bool isLightOn = building.lights[i];

      _paint.color = isLightOn ? colorSamoanSun : colorBlueStone;

      final x = building.width / 4 * (column * 2 + 1);
      final y = buildingRect.top + windowStrokeWidth * (row * 2 + 1);

      canvas.drawLine(
          Offset(x, y), Offset(x, y + windowStrokeWidth * 1.2), _paint);
    }

    bool isDownwarding;

    if (building.hasGuideLight || building.hasLightingLoad) {
      isDownwarding = building.previousWallHeight != null &&
          building.previousWallHeight > building.height;
    }

    if (building.hasGuideLight) {
      _paint.strokeCap = StrokeCap.round;
      _paint.strokeWidth = windowStrokeWidth / 2;
      _paint.color = colorFlameScarlet;
      if (isDownwarding) {
        canvas.drawPoints(PointMode.points,
            [Offset(building.width - 0.1, buildingRect.top)], _paint);
      } else {
        canvas.drawPoints(
            PointMode.points, [Offset(0.1, buildingRect.top)], _paint);
      }
    }

    if (building.hasLightingLoad) {
      _paint.strokeCap = StrokeCap.square;
      _paint.color = colorOuterSpace;
      _paint.strokeWidth = windowStrokeWidth / 4;

      final x = isDownwarding
          ? building.width - windowStrokeWidth
          : windowStrokeWidth;

      canvas.drawLine(Offset(x, 0), Offset(x, lightingLoadHeight), _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
