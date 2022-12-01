import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelTheme(),
      child: Consumer<ModelTheme>(
          builder: (context, ModelTheme themeNotifier, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeNotifier.isDark ? darkTheme() : lightTheme(),
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(),
        );
      }),
    );
  }
}

ThemeData darkTheme() {
  return ThemeData(
      fontFamily: 'Rubik-Regular',
      primaryColor: const Color(0xFF7165ca),
      cardColor: const Color(0xFF282b38),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF23232b)),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF23232b),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          backgroundColor: Color(0xFF7165ca)));
}

ThemeData lightTheme() {
  return ThemeData(
      fontFamily: 'Rubik-Regular',
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.blueGrey),
      primaryColor: Colors.blueGrey,
      scaffoldBackgroundColor: const Color(0xFFEFEFEF));
}

class MyThemePreferences {
  static const themeKey = "theme_key";

  setTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(themeKey, value);
  }

  getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(themeKey) ?? false;
  }
}

class ModelTheme extends ChangeNotifier {
  late bool _isDark;
  late MyThemePreferences _preferences;
  bool get isDark => _isDark;

  ModelTheme() {
    _isDark = false;
    _preferences = MyThemePreferences();
    getPreferences();
  }
//Switching the themes
  set isDark(bool value) {
    _isDark = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preferences.getTheme();
    notifyListeners();
  }
}
