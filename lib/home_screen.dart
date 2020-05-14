import 'dart:async';
import 'dart:math';

import 'package:chess_timer/countdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final Duration gameDuration = Duration(minutes: 4, seconds: 10);

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CountDown firstCountDown;
  CountDown secondCountDown;
  StreamSubscription<Duration> firstSubscription;
  StreamSubscription<Duration> secondSubscription;

  final GameState _firstGameState = GameState(remainingTime: gameDuration, moveCount: 0);
  final GameState _secondGameState = GameState(remainingTime: gameDuration, moveCount: 0);

  bool _isFirstPlaying = false;
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
    primaryColorLight: Color(0xFF784D9F),
    primaryColorDark: Color(0xFFFFBD59),
    canvasColor: Color(0xFFB1F1A0),
    errorColor: Color(0xFFE57373),
  );

  @override
  void initState() {
    firstCountDown = CountDown(gameDuration);
    secondCountDown = CountDown(gameDuration);

    firstSubscription = firstCountDown.stream.listen(_firstGameState.updateRemainingTime);
    secondSubscription = secondCountDown.stream.listen(_secondGameState.updateRemainingTime);

    firstSubscription.pause();
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
      if (!_secondPlayerReady || !_isFirstPlaying && _firstGameState.moveCount > 0) return;

      if (_firstGameState.moveCount > 0) {
        firstSubscription.pause();
        secondSubscription.resume();
      }
      setState(() {
        _secondMargin = 0;
        _firstMargin = 15;
      });

      _firstGameState.incrementMoveCount();

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
      if (!_firstPlayerReady || (_isFirstPlaying && _firstGameState.moveCount > 0) || !(_firstGameState.moveCount > 0)) return;

      if ((_secondGameState.moveCount > 0)) {
        secondSubscription.pause();
      }

      setState(() {
        firstSubscription.resume();
        _secondMargin = 15;
        _firstMargin = 0;
      });
      _secondGameState.incrementMoveCount();

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
              child: ChangeNotifierProvider.value(
                value: _secondGameState,
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
                        color: _secondLost ? _themeData1.errorColor : !_secondPlayerReady ? Colors.blueGrey : _themeData1.accentColor,
                        boxShadow: [
                          BoxShadow(blurRadius: _firstMargin),
                        ],
                        /*gradient: LinearGradient(
                                    colors: [
                                      _themeData1.accentColor,
                                      _themeData1.primaryColorDark,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),*/
                      ),
                      child: Consumer<GameState>(
                        builder: (context, GameState secondGameState, child) {
                          Duration _showedDuration = secondGameState.remainingTime;

                          int minutes = _showedDuration.inMinutes;
                          int seconds = _showedDuration.inSeconds % Duration.secondsPerMinute;
                          //int milliseconds = _showedDuration.inMilliseconds % (Duration.millisecondsPerMinute * Duration.millisecondsPerSecond);

                          String _showedValue = getTwoDigitString(minutes) + ":" + getTwoDigitString(seconds);

                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                Align(
                                  child: FittedBox(
                                    child: Text(
                                      _showedValue,
                                      style: TextStyle(fontSize: 200, color: _themeData1.primaryColorLight),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    secondGameState.moveCount.toString(),
                                    style: TextStyle(fontSize: 50, color: _themeData1.primaryColorLight),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // FIRST PLAYER
            Expanded(
              flex: 1,
              child: ChangeNotifierProvider.value(
                value: _firstGameState,
                child: GestureDetector(
                  onTapUp: (TapUpDetails tapUpDetails) => onPlayerTap(isFirstPlayer: true),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    margin: EdgeInsets.all(_firstMargin),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: _firstLost ? _themeData1.errorColor : !_firstPlayerReady ? Colors.grey : _themeData1.primaryColor,
                        borderRadius: BorderRadius.circular(_firstMargin),
                        boxShadow: [
                          BoxShadow(blurRadius: _secondMargin),
                        ]),
                    child: Consumer<GameState>(
                      builder: (context, GameState firstGameState, child) {
                        Duration _showedDuration = firstGameState.remainingTime;

                        int minutes = _showedDuration.inMinutes;
                        int seconds = _showedDuration.inSeconds % Duration.secondsPerMinute;
                        //int milliseconds = duration.inMilliseconds ;

                        String _showedValue = getTwoDigitString(minutes) + ":" + getTwoDigitString(seconds);

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Stack(
                            children: [
                              Align(
                                child: FittedBox(
                                  child: Text(
                                    _showedValue,
                                    style: TextStyle(fontSize: 200, color: _themeData1.primaryColorDark),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  firstGameState.moveCount.toString(),
                                  style: TextStyle(fontSize: 50, color: _themeData1.primaryColorDark),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                    color: _themeData1.primaryColorDark,
                    child: Icon(
                      Icons.settings,
                      size: 30,
                      color: _themeData1.primaryColorLight,
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
                  color: _themeData1.primaryColorDark,
                  child: Icon(
                    _gameEnded ? Icons.replay : _gamePaused ? Icons.play_arrow : Icons.pause,
                    size: 30,
                    color: _themeData1.primaryColorLight,
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
                    color: _themeData1.primaryColorDark,
                    child: Icon(
                      Icons.palette,
                      size: 30,
                      color: _themeData1.primaryColorLight,
                    ),
                    padding: EdgeInsets.all(4),
                    onPressed: () {
                      if (!_gamePaused) return;
                    },
                    shape: CircleBorder(),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Change GameState Model to PlayerState and make a GameState model with all the booleans variables on game state.

class GameState extends ChangeNotifier {
  Duration remainingTime;
  int moveCount;

  GameState({this.remainingTime, this.moveCount});

  void incrementMoveCount() {
    moveCount += 1;
    notifyListeners();
  }

  void updateRemainingTime(Duration remainingTime) {
    this.remainingTime = remainingTime.abs();
    notifyListeners();
  }

  void initialize() {
    remainingTime = Duration();
    moveCount = 0;
    notifyListeners();
  }
}
