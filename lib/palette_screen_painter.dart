import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:vector_math/vector_math.dart' as v;

class PaletteScreenPainter extends CustomPainter {
  PaletteScreenPainter({@required this.theme});

  final ThemeData theme;

  Path _drawDroplet(Point<double> start, double dropUnit) {
    return Path()
      ..moveTo(start.x, start.y)
      ..lineTo(start.x - dropUnit, start.y)
      ..relativeQuadraticBezierTo(dropUnit, 2.5*dropUnit, 0,  5*dropUnit)
      ..relativeArcToPoint(Offset(2*dropUnit, 0), radius: Radius.circular(dropUnit),rotation: pi, clockwise : false)
      ..relativeQuadraticBezierTo(-dropUnit, -2.5*dropUnit, 0, -5*dropUnit)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final accentPaint = Paint()..color = theme.accentColor;
    final primaryPaint = Paint()..color = theme.primaryColor;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), primaryPaint);

    final double alpha = 20;

    final Point<double> firstPoint = Point(size.width / 4, size.height / 4);
    final Point<double> secondPoint = Point(size.width / 2, size.height / 2);
    final Point<double> thirdPoint = Point(3 * size.width / 4, 3 * size.height / 4);

    final double dropUnit = 10;
    final Path firstDrop = _drawDroplet(firstPoint, dropUnit);
    final Path secondDrop = _drawDroplet(thirdPoint, dropUnit);

    final Path accentPath = Path()
      ..quadraticBezierTo(0, size.height / 4, firstPoint.x, firstPoint.y)
      ..quadraticBezierTo(size.width / 2 - alpha, size.height / 4, secondPoint.x, secondPoint.y)
      ..quadraticBezierTo(size.width / 2 + alpha, 3 * size.height / 4, thirdPoint.x, thirdPoint.y)
      ..quadraticBezierTo(size.width, 3 * size.height / 4, size.width, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0);

    
    final Path backPath = Path()
      ..moveTo(0, size.height*0.8)
      ..cubicTo(0, size.height*0.85, size.width*0.15, size.height*0.85, size.width*0.15, size.height*0.9)
      ..cubicTo(size.width*0.15, size.height*0.95, 0, size.height*0.95, 0, size.height)
      ..lineTo(0, size.height*0.8);

    //10
    canvas.drawPath(accentPath, accentPaint);
    canvas.drawPath(backPath, accentPaint);
    //canvas.drawPath(firstDrop, accentPaint);
    //canvas.drawPath(secondDrop, accentPaint);
  }

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(PaletteScreenPainter oldDelegate) => false;
}

/*
class Colored extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = v.SimplexNoise();
    final frames = 200;
    canvas.drawPaint(Paint()..color = Colors.black87);

    for (double i = 10; i < frames; i += .1) {
      canvas.translate(i % .3, i % .6);
      canvas.save();
      canvas.rotate(pi / i * 25);

      final area = Offset(i, i) & Size(i * 10, i * 10);

      // Blue trail is made of rectangle
      canvas.drawRect(
          area,
          Paint()
            ..filterQuality =
                FilterQuality.high // Change this to lower render time
            ..blendMode =
                BlendMode.screen // Remove this to see the natural drawing shape
            ..color =
                // Addition of Opacity gives you the fading effect from dark to light
                Colors.blue.withRed(i.toInt() * 20 % 11).withOpacity(i / 850));

      // Tail particles effect

      // Change this to add more fibers
      final int tailFibers = (i * 1.5).toInt();

      for (double d = 0; d < area.width; d += tailFibers) {
        for (double e = 0; e < area.height; e += tailFibers) {
          final n = random.noise2D(d, e);
          final tail = exp(i / 50) - 5;
          final tailWidth = .2 + (i * .11 * n);
          canvas.drawCircle(
              Offset(d, e),
              tailWidth,
              Paint()
                ..color = Colors.red.withOpacity(.4)
                ..isAntiAlias = true // Change this to lower render time
                // Particles accelerate as they fall so we change the blur size for movement effect
                ..imageFilter = ImageFilter.blur(sigmaX: tail, sigmaY: 0)
                ..filterQuality =
                    FilterQuality.high // Change this to lower render time
                ..blendMode = BlendMode
                    .screen); // Remove this to see the natural drawing shape
        }
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}*/
