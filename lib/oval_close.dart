import 'package:flutter/material.dart';

class OvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print(size);
    Paint _paint = Paint()
      ..color = Colors.red
      ..isAntiAlias = true;
      canvas.drawOval(Rect.fromPoints(
          Offset(60, 175),
          Offset(360, 550),
        ), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}