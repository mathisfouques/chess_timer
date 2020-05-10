import 'package:flutter/material.dart';

import './home_screen.dart';
import 'radial_progress.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final bool test = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: test ? Scaffold(body: RadialProgress()) : HomeScreen(),
    );
  }
}

