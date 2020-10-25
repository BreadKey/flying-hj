import 'package:flutter/material.dart';
import 'package:flying_hj/colors.dart';
import 'package:flying_hj/game/foundation/game_object.dart';

class Moon extends GameObject with ChangeNotifier {
  Moon() : super(5, 5, 5, 5);

  @override
  void setPoint(Offset point) {
    super.setPoint(point);
    notifyListeners();
  }

  @override
  Widget get sprite => CustomPaint(
        painter: _MoonPainter(),
      );
}

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = colorSamoanSun);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
