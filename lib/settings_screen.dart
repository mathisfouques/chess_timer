import 'package:chess_timer/home_screen.dart';
import 'package:chess_timer/settings_screen_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: themeData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          ThemeData currentThemeData = snapshot.data;

          SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: currentThemeData.primaryColor));

          return CustomPaint(
            painter: SettingsScreenPainter(theme: currentThemeData),
            child: Stack(
              children: <Widget>[
                Positioned.fromRect(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: currentThemeData.primaryColor,
                          size: (MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.width) * 0.09,
                        ),
                      ),
                      rect: Rect.fromCircle(
                        center: Offset(MediaQuery.of(context).size.width * 0.925, MediaQuery.of(context).size.height * 0.9),
                        radius: MediaQuery.of(context).size.width * (MediaQuery.of(context).orientation == Orientation.landscape ? 0.3 : 0.5),
                      ),
                    )
              ],
            ),
          );
        },
      ),
    );
  }
}

class Setting {
  Duration gameDuration;
  Duration increment;
  
}
