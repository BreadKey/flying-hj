import 'package:flutter/material.dart';
import 'package:flying_hj/game/flyer.dart';
import 'package:flying_hj/game/item.dart';

class StraightBlock extends Item {
  StraightBlock(double activeTime) : super(1.6, 1.6, activeTime);

  double _lastVelocityX;

  @override
  Widget get sprite => Material(
        color: Colors.amber,
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        child: const Icon(
          Icons.forward,
          color: Colors.white,
          size: 48,
        ),
      );

  @override
  void active(Flyer flyer) {
    flyer.y = y;
    _lastVelocityX = flyer.velocityX;
    flyer.velocityX *= 2;
    flyer.velocityY = 0;
    flyer.accelerationY = 0;
    flyer.fly();
  }

  @override
  void update(Flyer flyer) {
    if (flyer.accelerationY < 0) {
      flyer.accelerationY = 0;
    }
  }

  @override
  void end(Flyer flyer) {
    flyer.velocityX = _lastVelocityX;
    flyer.endFly();
  }
}