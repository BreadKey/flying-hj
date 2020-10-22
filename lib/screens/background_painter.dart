import 'package:flutter/material.dart';
import 'package:flying_hj/colors.dart';

class BackgroundPainter extends StatelessWidget {
  const BackgroundPainter({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _BackgroundPainter(),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()..color = colorOuterSpace.withOpacity(0.1618);
    final delta = size.width / 10;

    path.moveTo(0, size.height);
    path.lineTo(size.width * 2, size.height);
    path.relativeLineTo(0, -size.height * 0.1618 * 1.618 - delta / 2);
    path.relativeLineTo(-size.width, 0);
    path.relativeLineTo(-delta, 0);
    path.relativeLineTo(0, delta / 2);
    path.relativeLineTo(-delta, 0);
    path.relativeLineTo(0, -delta);
    path.relativeLineTo(-delta, 0);
    path.relativeLineTo(0, delta);
    path.relativeLineTo(-delta * 2, 0);
    path.relativeLineTo(0, -delta / 2);
    path.relativeLineTo(-delta, 0);
    path.relativeLineTo(0, delta * 0.5);
    path.relativeLineTo(-delta * 0.25, 0);
    path.relativeLineTo(0, delta * 0.25);
    path.relativeLineTo(-delta * 2.5, 0);
    path.relativeLineTo(0, -delta / 2);
    path.relativeLineTo(-delta / 2, 0);
    path.relativeLineTo(0, -delta);
    path.relativeLineTo(-delta, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
