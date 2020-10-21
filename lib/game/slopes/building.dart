import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flying_hj/colors.dart';
import 'package:flying_hj/game/slope.dart';

const double lightingLoadHeight = 1;

class Building extends Slope {
  final List<bool> lights = [];
  bool hasGuideLight;
  bool hasLightingLoad;

  Building(double width, double height,
      {double previousBuildingHeight,
      bool fromTop = false,
      double centerX,
      bool canHasLightingLoad})
      : super(width, height,
            previousSlopeHeight: previousBuildingHeight,
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

    hasLightingLoad = canHasLightingLoad && Random().nextInt(20) == 0;
  }

  @override
  Widget get sprite => Container(
        child: CustomPaint(
          painter: _BuildingPainter(this),
        ),
      );
}

class _BuildingPainter extends CustomPainter {
  final Building building;
  final Rect buildingRect;

  _BuildingPainter(this.building)
      : this.buildingRect = Rect.fromLTWH(
            0,
            building.hasLightingLoad ? lightingLoadHeight : 0,
            building.width + 0.01,
            building.height);

  @override
  void paint(Canvas canvas, Size size) {
    final ratio = size.width / building.width;
    final paint = Paint();

    canvas.scale(ratio);

    paint.color = colorOuterSpace;

    canvas.drawRect(buildingRect, paint);

    final windowStrokeWidth = building.width / 3;

    paint.strokeWidth = windowStrokeWidth;

    for (int i = 0; i < building.lights.length; i++) {
      final column = i % 2;
      final row = i ~/ 2;
      bool isLightOn = building.lights[i];

      paint.color = isLightOn ? colorSamoanSun : colorBlueStone;

      final x = building.width / 4 * (column * 2 + 1);
      final y = buildingRect.top + windowStrokeWidth * (row * 2 + 1);

      canvas.drawLine(
          Offset(x, y), Offset(x, y + windowStrokeWidth * 1.2), paint);
    }

    if (building.hasGuideLight) {
      paint.strokeCap = StrokeCap.round;
      paint.strokeWidth = windowStrokeWidth / 2;
      paint.color = colorFlameScarlet;
      if (building.previousSlopeHeight != null &&
          building.previousSlopeHeight > building.height) {
        canvas.drawPoints(PointMode.points,
            [Offset(building.width - 0.1, buildingRect.top)], paint);
      } else {
        canvas.drawPoints(
            PointMode.points, [Offset(0.1, buildingRect.top)], paint);
      }
    }

    if (building.hasLightingLoad) {
      paint.strokeCap = StrokeCap.square;
      paint.color = colorOuterSpace;
      paint.strokeWidth = windowStrokeWidth / 4;

      canvas.drawLine(Offset(windowStrokeWidth, 0),
          Offset(windowStrokeWidth, lightingLoadHeight), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
