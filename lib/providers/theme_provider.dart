import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/color_scheme.dart';

class MyThemePreferences {
  static const themeKey = 'theme_key';

  Future<void> setTheme(bool value) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setBool(themeKey, value);
  }

  Future<bool> getTheme() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getBool(themeKey) ?? false;
  }
}

class ModelTheme extends ChangeNotifier {
  ModelTheme() {
    _isDark = false;
    _colorTheme = DarkColorTheme();
    initialize();
  }
  late bool _isDark;

  final MyThemePreferences _preferences = MyThemePreferences();

  bool get isDark => _isDark;

  late ColorTheme _colorTheme;

  ColorTheme get colorTheme => _colorTheme;

  Future<void> initialize() async {
    await getPreferences();
  }

  void changeTheme() {
    _isDark = !_isDark;
    _colorTheme = _isDark ? DarkColorTheme() : LightColorTheme();
    notifyListeners();
  }

  set isDark(bool value) {
    _isDark = value;
    _colorTheme = _isDark ? DarkColorTheme() : LightColorTheme();
    _preferences.setTheme(value);
    notifyListeners();
  }

  Future<void> getPreferences() async {
    _isDark = await _preferences.getTheme();
    _colorTheme = _isDark ? DarkColorTheme() : LightColorTheme();
    notifyListeners();
  }
}
