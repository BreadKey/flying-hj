import 'package:flutter/material.dart';
import 'package:flying_hj/colors.dart';
import 'package:flying_hj/game/foundation/game_object.dart';

class Moon extends GameObject with ChangeNotifier {
  Moon() : super(4, 4, 4, 4);

  @override
  void setPoint(Offset point) {
    super.setPoint(point);
    notifyListeners();
  }

  @override
  Widget get sprite => RepaintBoundary(
        child: Image.asset(
          "assets/moon.png",
          filterQuality: FilterQuality.none,
          fit: BoxFit.contain,
        ),
      );
}