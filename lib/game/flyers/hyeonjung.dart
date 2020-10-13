import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flying_hj/game/flyer.dart';

class Hyeonjung extends Flyer {
  Hyeonjung() : super(20, 20, 12, 6);

  Timer _flyTimer;

  bool isFlying = false;

  @override
  void dispose() {
    _flyTimer?.cancel();
  }

  static final _images = List.generate(
      20,
      (index) => Image.asset(
            "assets/hj/frame${index + 1}.png",
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
            gaplessPlayback: true,
          ));

  int _currentImageIndex = 0;

  @override
  Image get sprite => _images[_currentImageIndex];

  @override
  void start() {
    int tick = 0;
    isFlying = false;

    _flyTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      tick++;

      if (isFlying || tick % 2 == 0) {
        _currentImageIndex++;
        if (_currentImageIndex == _images.length) {
          _currentImageIndex = 0;
        }
      }
    });
  }

  @override
  void dead() {
    _currentImageIndex = 0;
    _flyTimer?.cancel();
  }

  @override
  void fly() {
    isFlying = true;
  }

  @override
  void endFly() {
    isFlying = false;
  }
}
