import 'dart:async';
import 'dart:math';

import 'package:chess_timer/countdown.dart';
import 'package:chess_timer/palette_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Duration gameDuration = Duration(minutes: 5);

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

  Future<ThemeData> _themeData() async {
    var prefs = await SharedPreferences.getInstance();

    return themes[prefs.get('theme') ?? 0];
  }

  void _resetGame() {
    _firstGameState.resetWithSpecificDuration(gameDuration);
    _secondGameState.resetWithSpecificDuration(gameDuration);

    firstCountDown = CountDown(gameDuration);
    secondCountDown = CountDown(gameDuration);

    firstSubscription = firstCountDown.stream.listen(_firstGameState.updateRemainingTime);
    secondSubscription = secondCountDown.stream.listen(_secondGameState.updateRemainingTime);

    firstSubscription.pause();
    secondSubscription.pause();

    _isFirstPlaying = false;
    _firstPlayerReady = false;
    _secondPlayerReady = false;
    _gamePaused = false;
    _gameEnded = false;
    _firstLost = false;
    _secondLost = false;

    _firstMargin = 0;
    _secondMargin = 0;

    // On game ended :
    firstSubscription.onDone(() {
      setState(() {
        _gameEnded = true;
        _firstLost = true;
      });
      showDialog(
        context: context,
        builder: (context) {
          return CustomDialog(
            onReset: () {
              _resetGame();
              Navigator.pop(context);
              setState(() {});
            },
            player: "First",
          );
        },
      );
    });

    secondSubscription.onDone(() {
      setState(() {
        _gameEnded = true;
        _secondLost = true;
      });
      showDialog(
        context: context,
        builder: (context) {
          return CustomDialog(
            onReset: () {
              _resetGame();
              Navigator.pop(context);
              setState(() {});
            },
            player: "Second",
          );
        },
      );
    });
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    _resetGame();

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

      SystemSound.play(SystemSoundType.click);

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

      SystemSound.play(SystemSoundType.click);

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
      body: FutureBuilder(
        future: _themeData(),
        builder: (context, themeDataSnapshot) {
          if (!themeDataSnapshot.hasData) {
            return Container();
          }

          ThemeData currentThemeData = themeDataSnapshot.data as ThemeData;

          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: currentThemeData.primaryColor));

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [currentThemeData.backgroundColor, currentThemeData.canvasColor],
                end: Alignment.bottomRight,
                begin: Alignment.topLeft,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
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
                                color: _secondLost
                                    ? currentThemeData.errorColor
                                    : currentThemeData.accentColor,
                                boxShadow: [
                                  BoxShadow(blurRadius: _firstMargin, color: currentThemeData.accentColor),
                                ],
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
                                              style: TextStyle(fontSize: 200, color: currentThemeData.primaryColorLight),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            !_secondPlayerReady ? "Tap" : secondGameState.moveCount.toString(),
                                            style: TextStyle(fontSize: 50, color: currentThemeData.primaryColorLight),
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
                              color: _firstLost
                                  ? currentThemeData.errorColor
                                  : currentThemeData.primaryColor,
                              borderRadius: BorderRadius.circular(_firstMargin),
                              boxShadow: [BoxShadow(blurRadius: _secondMargin, color: currentThemeData.primaryColor)],
                            ),
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
                                            style: TextStyle(fontSize: 200, color: currentThemeData.primaryColorDark),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          !_firstPlayerReady ? "Tap" : firstGameState.moveCount.toString(),
                                          style: TextStyle(fontSize: 50, color: currentThemeData.primaryColorDark),
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
                  ],
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 1000),
                        opacity: _gamePaused ? 1.0 : 0.0,
                        curve: Curves.fastLinearToSlowEaseIn,
                        child: RaisedButton(
                          color: currentThemeData.primaryColorDark,
                          child: Icon(
                            Icons.settings,
                            size: 30,
                            color: currentThemeData.primaryColorLight,
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
                        color: currentThemeData.primaryColorDark,
                        child: _gameEnded
                            ? Icon(Icons.replay, size: 30, color: currentThemeData.primaryColorLight)
                            : AnimatedCrossFade(
                                duration: Duration(milliseconds: 300),
                                crossFadeState: _gamePaused ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                firstChild: Icon(
                                  Icons.play_arrow,
                                  size: 30,
                                  color: currentThemeData.primaryColorLight,
                                ),
                                firstCurve: Curves.bounceInOut,
                                secondChild: Icon(
                                  Icons.pause,
                                  size: 30,
                                  color: currentThemeData.primaryColorLight,
                                ),
                                secondCurve: Curves.bounceInOut,
                              ),
                        padding: EdgeInsets.all(4),
                        onPressed: () {
                          if (_gameEnded) {
                            _resetGame();
                            setState(() {});
                          }

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
                          color: currentThemeData.primaryColorDark,
                          child: Icon(
                            Icons.palette,
                            size: 30,
                            color: currentThemeData.primaryColorLight,
                          ),
                          padding: EdgeInsets.all(4),
                          onPressed: () {
                            if (!_gamePaused) return;

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaletteScreen(),
                                ));
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
        },
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({Key key, @required this.onReset, @required this.player}) : super(key: key);

  final Function onReset;
  final String player;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 3,
        horizontal: MediaQuery.of(context).size.width / 8,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      decoration: BoxDecoration(color: Color(0xFFE57373), borderRadius: BorderRadius.circular(15)),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("$player clock ran out ! ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                )),
            SizedBox(height: 10),
            RaisedButton(
              onPressed: onReset,
              color: Colors.white,
              child: Text("RESET", style: TextStyle(color: Colors.red, fontSize: 20)),
            ),
          ],
        ),
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

  void resetWithSpecificDuration(Duration duration) {
    this.remainingTime = duration.abs();
    this.moveCount = 0;
    notifyListeners();
  }
}
