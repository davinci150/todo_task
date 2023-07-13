import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../dao/theme_dao.dart';
import '../presentation/color_scheme.dart';

class ModelTheme extends ChangeNotifier {
  ModelTheme() {
    _isDark = false;
    _colorTheme = DarkColorTheme();
    getPreferences();
  }
  late bool _isDark;

  bool get isDark => _isDark;

  late ColorTheme _colorTheme;

  ColorTheme get colorTheme => _colorTheme;

  void changeTheme() {
    _isDark = !_isDark;
    _colorTheme = _isDark ? DarkColorTheme() : LightColorTheme();
    GetIt.I<ThemeDao>().setTheme(_isDark);

    notifyListeners();
  }

  Future<void> getPreferences() async {
    _isDark = await GetIt.I<ThemeDao>().getTheme();
    _colorTheme = _isDark ? DarkColorTheme() : LightColorTheme();
    notifyListeners();
  }
}
