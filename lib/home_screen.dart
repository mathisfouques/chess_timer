import 'dart:async';
import 'dart:math';

import 'package:chess_timer/countdown.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Duration _gameDuration = Duration(minutes: 0, seconds: 10);

  CountDown firstCountDown;
  CountDown secondCountDown;
  StreamSubscription<Duration> firstSubscription;
  StreamSubscription<Duration> secondSubscription;

  final ValueNotifier<Duration> firstRemainingTime = ValueNotifier<Duration>(Duration());
  final ValueNotifier<Duration> secondRemainingTime = ValueNotifier<Duration>(Duration());

  bool _isFirstPlaying = false;
  bool _firstMovePlayed = false;
  bool _secondMovePlayed = false;
  bool _firstPlayerReady = false;
  bool _secondPlayerReady = false;
  bool _gamePaused = false;
  bool _gameEnded = false;
  bool _firstLost = false;
  bool _secondLost = false;

  double _firstMargin = 0, _secondMargin = 0;

  // Stylish Red : Color(0xFFE57373)

  ThemeData _themeData1 = ThemeData(
    primaryColor: Color(0xFF51356A),
    accentColor: Color(0xFFFAA526),
    canvasColor: Color(0xFFC4D4C0),
    disabledColor: Colors.red,
  );

  void _initCountdown() {
    firstCountDown = CountDown(_gameDuration);
    secondCountDown = CountDown(_gameDuration);

    firstSubscription = firstCountDown.stream.listen(null);
    secondSubscription = secondCountDown.stream.listen(null);

    setState(() {
      _isFirstPlaying = false;
      _firstMovePlayed = false;
      _firstPlayerReady = false;
      _secondPlayerReady = false;
      _gamePaused = false;
      _gameEnded = false;
      _firstLost = false;
      _secondLost = false;
    });
  }

  @override
  void initState() {
    firstCountDown = CountDown(_gameDuration);
    secondCountDown = CountDown(_gameDuration);

    firstSubscription = firstCountDown.stream.listen(null);
    secondSubscription = secondCountDown.stream.listen(null);

    firstSubscription.onData((Duration remainingTime) {
      firstRemainingTime.value = remainingTime;
    });
    // Directly pauses the sub after starting it. Not optimal needs change
    firstSubscription.pause();

    secondSubscription.onData((Duration remainingTime) {
      secondRemainingTime.value = remainingTime;
    });
    secondSubscription.pause();

    // On game ended :
    firstSubscription.onDone(() {
      setState(() {
        _gameEnded = true;
        _firstLost = true;
      });
    });

    secondSubscription.onDone(() {
      _gameEnded = true;
      _secondLost = true;
    });

    super.initState();
  }

  @override
  void dispose() {
    firstSubscription.cancel();
    secondSubscription.cancel();

    super.dispose();
  }

  void onPlayerTap({@required bool isFirstPlayer}) {
    if (_gamePaused) return;
    if (_gameEnded) return;

    if (isFirstPlayer) {
      // First player
      if (!_firstPlayerReady) {
        setState(() {
          _firstPlayerReady = true;
        });
        return;
      }
      if (!_secondPlayerReady) return;

      if (!_isFirstPlaying && _firstMovePlayed) return;

      assert(_firstPlayerReady && _secondPlayerReady && (_isFirstPlaying || !_firstMovePlayed));

      if (!_firstMovePlayed) {
        _firstMovePlayed = true;
        return;
      }

      firstSubscription.pause();
      secondSubscription.resume();
      setState(() {
        _secondMargin = 0;
        _firstMargin = 15;
      });
      _isFirstPlaying = false;
    } else {
      // Second player

      if (!_secondPlayerReady) {
        setState(() {
          _secondPlayerReady = true;
          _secondMargin = 15;
        });
        return;
      }
      if (!_firstPlayerReady) return;

      if (_isFirstPlaying && _firstMovePlayed) return;

      if (!_firstMovePlayed) return;

      assert(_firstPlayerReady && _secondPlayerReady && !_isFirstPlaying && _firstMovePlayed);

      if (!_secondMovePlayed) {
        _secondMovePlayed = true;
      }
      else{
        firstSubscription.resume();
      }

      secondSubscription.pause();
      setState(() {
        _secondMargin = 15;
        _firstMargin = 0;
      });

      _isFirstPlaying = true;
    }
  }

  String getTwoDigitString(int number) {
    return number < 10 ? "0" + number.toString() : number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeData1.canvasColor,
      body: Stack(
        children: [
          Column(children: [
            // SECOND PLAYER

            Expanded(
              flex: 1,
              child: GestureDetector(
                // Allow to get invoked as soon as the user touch the screen.
                onTapUp: (TapUpDetails _) {
                  onPlayerTap(isFirstPlayer: false);
                },
                child: Transform.rotate(
                  angle: pi,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    margin: EdgeInsets.all(_secondMargin),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_secondMargin),
                        color: _secondLost ? _themeData1.disabledColor : !_secondPlayerReady ? Colors.blueGrey : _themeData1.accentColor,
                        boxShadow: [
                          BoxShadow(blurRadius: _firstMargin),
                        ]),
                    /*decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF213275),
                                  Color(0xFFAD4A20),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [0.2, 0.2],
                              ),
                            ),*/
                    child: Center(
                      child: FittedBox(
                        child: ValueListenableBuilder(
                          valueListenable: secondRemainingTime,
                          builder: (context, Duration duration, child) {
                            Duration _showedDuration = _secondMovePlayed ? duration : _gameDuration;

                            int minutes = _showedDuration.inMinutes;
                            int seconds = _showedDuration.inSeconds % Duration.secondsPerMinute;
                            //int milliseconds = _showedDuration.inMilliseconds % (Duration.millisecondsPerMinute * Duration.millisecondsPerSecond);

                            String _showedValue =
                                getTwoDigitString(minutes) + ":" + getTwoDigitString(seconds); //+ ":" + getTwoDigitString(milliseconds);

                            return Text(
                              _showedValue,
                              style: TextStyle(fontSize: 200, color: Colors.black),
                              maxLines: 1,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // FIRST PLAYER
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTapUp: (TapUpDetails tapUpDetails) => onPlayerTap(isFirstPlayer: true),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastLinearToSlowEaseIn,
                  margin: EdgeInsets.all(_firstMargin),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: _firstLost ? _themeData1.disabledColor : !_firstPlayerReady ? Colors.grey : _themeData1.primaryColor,
                      borderRadius: BorderRadius.circular(_firstMargin),
                      boxShadow: [
                        BoxShadow(blurRadius: _secondMargin),
                      ]),
                  child: Center(
                    child: FittedBox(
                      child: ValueListenableBuilder(
                        valueListenable: firstRemainingTime,
                        builder: (context, Duration duration, child) {
                          Duration _showedDuration = _firstMovePlayed ? duration : _gameDuration;

                          int minutes = _showedDuration.inMinutes;
                          int seconds = _showedDuration.inSeconds % Duration.secondsPerMinute;
                          //int milliseconds = duration.inMilliseconds ;

                          String _showedValue =
                              getTwoDigitString(minutes) + ":" + getTwoDigitString(seconds); //+ ":" + getTwoDigitString(milliseconds);

                          return Text(
                            _showedValue,
                            style: TextStyle(fontSize: 200, color: Colors.white),
                            maxLines: 1,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedOpacity(
                  duration: Duration(milliseconds: 1000),
                  opacity: _gamePaused ? 1.0 : 0.0,
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: RaisedButton(
                    child: Icon(
                      Icons.settings,
                      size: 30,
                    ),
                    padding: EdgeInsets.all(4),
                    onPressed: () {
                      if (!_gamePaused) return;
                    },
                    shape: CircleBorder(),
                    elevation: 5,
                  ),
                ),
                RaisedButton(
                  child: Icon(
                    _gameEnded ? Icons.replay : _gamePaused ? Icons.play_arrow : Icons.pause,
                    size: 30,
                  ),
                  padding: EdgeInsets.all(4),
                  onPressed: () {
                    if (_gameEnded) {}

                    if (_isFirstPlaying) {
                      _gamePaused ? firstSubscription.resume() : firstSubscription.pause();
                    } else {
                      _gamePaused ? secondSubscription.resume() : secondSubscription.pause();
                    }
                    setState(() {
                      _gamePaused = !_gamePaused;
                    });
                  },
                  shape: CircleBorder(),
                  elevation: 5,
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 1000),
                  opacity: _gamePaused ? 1.0 : 0.0,
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: RaisedButton(
                    child: Icon(
                      Icons.palette,
                      size: 30,
                    ),
                    padding: EdgeInsets.all(4),
                    onPressed: () {
                      if (!_gamePaused) return;
                    },
                    shape: CircleBorder(),
                    elevation: 5,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Ideas :
// - Wrap the two Expanded into one widget so it is easy to configurate. Especially if for exemple we create a swap button to swap colors so that the phone doesn't need to be truned over.
