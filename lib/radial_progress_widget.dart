import 'package:flutter/material.dart';
import 'dart:math';

class RadialProgressWidget extends AnimatedWidget {
  const RadialProgressWidget({Key key, AnimationController controller}) : super(key: key, listenable: controller);

  Animation<double> get _progress => listenable;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      child: CustomPaint(
        foregroundPainter: MyPainter(
          lineColor: Colors.white,
          completeColor: Colors.purple,
          completePercent: Curves.easeInOut.transform(_progress.value),
          width: 3.0,
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter{
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;
  MyPainter({this.lineColor,this.completeColor,this.completePercent,this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint( )
        ..color = lineColor
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = width;
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center  = new Offset(size.width/2, size.height/2);
    double radius  = min(size.width/2,size.height/2) - width / 2 ;
    canvas.drawCircle(
        center,
        radius,
        line
    );
    double arcAngle = 2*pi* (completePercent);
    canvas.drawArc(
        new Rect.fromCircle(center: center,radius: radius),
        -pi/2,
        arcAngle,
        false,
        complete
    );
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
