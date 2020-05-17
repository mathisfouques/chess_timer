import 'package:flutter/material.dart';

class SettingsScreenPainter extends CustomPainter {
  SettingsScreenPainter({@required this.theme});

  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final accentPaint = Paint()..color = theme.accentColor;
    final primaryPaint = Paint()..color = theme.primaryColor;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), primaryPaint);

    final Path backPath = Path()
      ..moveTo(size.width, size.height * 0.8)
      ..cubicTo(size.width, size.height * 0.85, size.width * 0.85, size.height * 0.85, size.width * 0.85, size.height * 0.9)
      ..cubicTo(size.width * 0.85, size.height * 0.95, size.width, size.height * 0.95, size.width, size.height)
      ..lineTo(size.width, size.height * 0.8);

    canvas.drawPath(backPath, accentPaint);
  }

  @override
  bool shouldRepaint(SettingsScreenPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(SettingsScreenPainter oldDelegate) => false;
}
