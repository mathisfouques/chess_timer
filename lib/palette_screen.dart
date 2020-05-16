import 'package:chess_timer/palette_screen_painter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData _themeData1 = ThemeData(
  primaryColor: Color(0xFF51356A),
  accentColor: Color(0xFFFAA526),
  primaryColorLight: Color(0xFF784D9F),
  primaryColorDark: Color(0xFFFFBD59),
  backgroundColor: Color(0xFF72B7DF),
  canvasColor: Color(0xFFB1F1A0),
  errorColor: Color(0xFFE57373),
);

ThemeData _themeData2 = ThemeData(
  primaryColor: Color(0xFFFAEBDE),
  accentColor: Color(0xFF373737),
  primaryColorLight: Color(0xFFFFF8F2),
  primaryColorDark: Color(0xFF302E2D),
  backgroundColor: Color(0xFFFFFFFF),
  canvasColor: Color(0xE0FFFFFF),
  errorColor: Color(0xFFE57373),
);

ThemeData _themeData3 = ThemeData(
  primaryColor: Color(0xFFC4DFE6),
  accentColor: Color(0xFF003B46),
  primaryColorLight: Color(0xFFC4DFE6),
  primaryColorDark: Color(0xFF07575B),
  backgroundColor: Color(0xFF66A5AD),
  canvasColor: Color(0xFF07575B),
  errorColor: Color(0xFFE57373),
);

ThemeData _themeData4 = ThemeData(
  primaryColor: Color(0xFFF4CC70),
  accentColor: Color(0xFFDE7A22),
  primaryColorLight: Color(0xFFF4CC70),
  primaryColorDark: Color(0xFFDE7A22),
  backgroundColor: Color(0xFF20948B),
  canvasColor: Color(0xFF6AB187),
  errorColor: Color(0xFFE57373),
);

ThemeData _themeData5 = ThemeData(
  primaryColor: Color(0xFFD09683),
  accentColor: Color(0xFF2D4262),
  primaryColorLight: Color(0xFFC4DFE6),
  primaryColorDark: Color(0xFFFAEBDE),
  backgroundColor: Color(0xFF363237),
  canvasColor: Color(0xFF73605B),
  errorColor: Color(0xFFE57373),
);

ThemeData _themeData6 = ThemeData(
  primaryColor: Color(0xFFCFEDAC),
  accentColor: Color(0xFF265C00),
  primaryColorLight: Color(0xFFFBFEF8),
  primaryColorDark: Color(0xFF265C00),
  backgroundColor: Color(0xFF68A225),
  canvasColor: Color(0xFFB3DE81),
  errorColor: Color(0xFFE57373),
);

ThemeData _themeData7 = ThemeData(
  primaryColor: Color(0xFFF4EADE),
  accentColor: Color(0xFFED8C72),
  primaryColorLight: Color(0xFFFFDCD3),
  primaryColorDark: Color(0xFFFF8565),
  backgroundColor: Color(0xFF2F496E),
  canvasColor: Color(0xFF2988BC),
  errorColor: Colors.red,
);

ThemeData _themeData8 = ThemeData(
  primaryColor: Color(0xFFFFEC5C),
  accentColor: Color(0xFF008DCB),
  primaryColorLight: Color(0xFFFFF295),
  primaryColorDark: Color(0xFF0075AB),
  backgroundColor: Color(0xFFE1315B),
  canvasColor: Color(0xFFF47D4A),
  errorColor: Color(0xFFE57373),
);

ThemeData _themeData9 = ThemeData(
  primaryColor: Color(0xFFFFEF7A),
  accentColor: Color(0xFF6BB28A),
  primaryColorLight: Color(0xFFFFF8C1),
  primaryColorDark: Color(0xFF466755),
  backgroundColor: Color(0xFFFFB6A3),
  canvasColor: Color(0xFFFFE9E3),
  errorColor: Color(0xFFE57373),
);

List<ThemeData> themes = [
  _themeData1,
  _themeData2,
  _themeData3,
  _themeData4,
  _themeData5,
  _themeData6,
  _themeData7,
  _themeData8,
  _themeData9
];

Future<void> _setTheme(int index) async {
  var prefs = await SharedPreferences.getInstance();

  await prefs.setInt('theme', index);
}

Future<ThemeData> _themeData() async {
  var prefs = await SharedPreferences.getInstance();

  return themes[prefs.get('theme') ?? 0];
}

class Indicator extends ValueNotifier<int> {
  Indicator(int value) : super(value);

  void updatePage(int page) {
    value = page;
    notifyListeners();
  }
}

class PaletteScreen extends StatefulWidget {
  PaletteScreen({Key key}) : super(key: key);

  @override
  _PaletteScreenState createState() => _PaletteScreenState();
}

class _PaletteScreenState extends State<PaletteScreen> {
  PageController _controller = PageController(viewportFraction: 0.8);
  Indicator _pageNumber = Indicator(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ThemeData>(
          future: _themeData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else {
              ThemeData currentThemeData = snapshot.data;

              return CustomPaint(
                painter: PaletteScreenPainter(theme: currentThemeData),
                child: Stack(
                  children: [
                    PageView(
                      physics: ClampingScrollPhysics(),
                      pageSnapping: true,
                      controller: _controller,
                      onPageChanged: (int index) {
                        _pageNumber.updatePage(index);
                      },
                      children: themes.map((ThemeData theme) {
                        int index = themes.indexOf(theme);

                        return GestureDetector(
                          onTap: () async {
                            _setTheme(index);
                            setState(() {});
                          },
                          child: StyleTheme(
                            theme: theme,
                            index: index,
                            indicator: _pageNumber,
                          ),
                        );
                      }).toList(),
                    ),
                    Positioned(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      top: MediaQuery.of(context).size.height * 0.8,
                      child: Center(
                        child: Container(
                          width: 200,
                          child: ValueListenableBuilder(
                            valueListenable: _pageNumber,
                            builder: (context, page, _) {
                              List<int> numbers = List.generate(themes.length, (int index) => index);

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: numbers.map((int index) {
                                  return AnimatedContainer(
                                    width: 10,
                                    duration: Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index == page ? currentThemeData.accentColor : currentThemeData.canvasColor),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}

class StyleTheme extends AnimatedWidget {
  const StyleTheme({Key key, this.theme, this.index, this.indicator}) : super(key: key, listenable: indicator);

  final ThemeData theme;
  final Indicator indicator;
  final int index;

  @override
  Widget build(BuildContext context) {
    final double top = indicator.value == index ? 50 : 150;
    final double blur = indicator.value == index ? 10 : 5;
    final double offset = indicator.value == index ? 10 : 3;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.fromLTRB(15, top, 15, 80),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            theme.backgroundColor,
            theme.canvasColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(offset: Offset(offset, offset), blurRadius: blur, color: Colors.black26),
        ],
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Center(
                  child: Text("5:00",
                      style: TextStyle(
                        color: theme.primaryColorLight,
                        fontSize: 100,
                      ))),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: theme.accentColor,
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Center(
                  child: Text("4:47",
                      style: TextStyle(
                        color: theme.primaryColorDark,
                        fontSize: 100,
                      ))),
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
