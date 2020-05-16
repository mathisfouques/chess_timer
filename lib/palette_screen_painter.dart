import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class PaletteScreenPainter extends CustomPainter {
  PaletteScreenPainter({@required this.theme});

  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    //1
    final accentPaint = Paint()..color = theme.accentColor;
    final primaryPaint = Paint()..color = theme.primaryColor;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), primaryPaint);

    //3
    final curvePath = Path()
      ..quadraticBezierTo(0, size.height, size.width, 0)
      ..close(); //9

    //10
    canvas.drawPath(curvePath, accentPaint);
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      // Annotate a rectangle containing the picture of the sun
      // with the label "Sun". When text to speech feature is enabled on the
      // device, a user will be able to locate the sun on this picture by
      // touch.
      var rect = Offset.zero & size;
      var width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return [
        CustomPainterSemantics(
          rect: rect,
          properties: SemanticsProperties(
            label: 'Sun',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(PaletteScreenPainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(PaletteScreenPainter oldDelegate) => false;
}
