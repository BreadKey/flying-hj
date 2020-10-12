import 'package:flutter/material.dart';
import 'package:flying_hj/game/field.dart';
import 'package:flying_hj/game/flyer.dart';

class TestField extends Field {
  @override
  int get width => 10000;
  int get height => 100;

  double x;

  List<Flyer> get hurdles => <Flyer>[
        Box(20, 70, 40),
        Box(20, 110, 70),
        Box(20, 140, 80),
      ];

  List<List<Flyer>> get walls => <List<Flyer>>[
        [Box(40, 70, 90), Box(40, 70, 10)],
        [Box(40, 90, 100), Box(40, 90, 20)],
        [Box(40, 110, 100), Box(40, 110, 10)],
        [Box(40, 130, 90), Box(40, 130, 10)],
        [Box(40, 150, 1100), Box(40, 150, 30)]
      ];
}

class Box extends Flyer {
  Box(double size, double x, double y) : super(size, size, size) {
    this.x = x;
    this.y = y;
  }

  @override
  void dead() {
    // TODO: implement dead
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void endFly() {
    // TODO: implement endFly
  }

  @override
  void fly() {
    // TODO: implement fly
  }

  @override
  // TODO: implement sprite
  Widget get sprite => Container(
        color: Colors.white,
      );

  @override
  void start() {
    // TODO: implement start
  }
}
