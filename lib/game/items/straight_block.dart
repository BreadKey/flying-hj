import 'package:flutter/material.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/item.dart';

class StraightBlock extends Item {
  final double airTime;
  final double distanceX;
  final double velocityX;
  StraightBlock(double activeTime, this.airTime, this.distanceX)
      : velocityX = distanceX / airTime,
        super(1.4, 1.4, 1.6, 1.6, activeTime);

  double _lastVelocityX;

  @override
  Widget get sprite => RepaintBoundary(
        child: Image.asset(
          "assets/americano.png",
          filterQuality: FilterQuality.none,
          fit: BoxFit.contain,
        ),
      );

  @override
  void active(Flyer flyer) {
    flyer.y = y;
    _lastVelocityX = flyer.velocityX;
    flyer.velocityX = velocityX;
    flyer.velocityY = 0;
    flyer.accelerationY = 0;
    flyer.fly();
  }

  @override
  void update(Flyer flyer) {
    if (flyer.accelerationY < 0) {
      flyer.accelerationY = 0;
    }
    flyer.velocityX = velocityX;
    flyer.fly();
  }

  @override
  void end(Flyer flyer) {
    flyer.velocityX = _lastVelocityX;
    if (flyer.velocityY == 0) {
      flyer.endFly();
    }
  }
}
