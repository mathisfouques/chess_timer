import 'package:chess_timer/radial_progress_widget.dart';
import 'package:flutter/material.dart';

class RadialProgress extends StatefulWidget {
  RadialProgress({
    Key key,
  }) : super(key: key);

  @override
  _RadialProgressState createState() => _RadialProgressState();
}

class _RadialProgressState extends State<RadialProgress> with TickerProviderStateMixin {
  AnimationController _percentageAnimationController;

  List<double> _progress = [0.33, 0.66, 1.0];
  int index = 0;

  @override
  void initState() {
    super.initState();

    _percentageAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 200),
          RadialProgressWidget(controller: _percentageAnimationController),
          RaisedButton(
            child: Text("Click"),
            onPressed: () {
              setState(() {
                if (index == _progress.length) {
                  _percentageAnimationController.reset();
                  index = 0;
                } else {
                  _percentageAnimationController.animateTo(_progress[index]);
                  index += 1;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
