import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_task/dao/tasks_dao.dart';
import 'package:todo_task/tasks_widget_model.dart';
import 'context_provider.dart';
import 'home_page.dart';
import 'themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TasksDao.instance.initialize();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyC32WB0mGBAEKSVz5ozz7_k2KdlurznicQ',
          appId: '1:668468006082:ios:2ff7f4830a135bcd79ff5b',
          messagingSenderId: '',
          projectId: 'todo-dcf3a'));

  runApp(ThemeModelProvider(model: ModelTheme(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeModelProvider.watch(context)?.model;

    return MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: navigatorKey,
        theme: theme?.isDark == true ? darkTheme : lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomePageWrapper());
  }
}

bool isDesktop = !Platform.isAndroid && !Platform.isIOS;

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
  final MyThemePreferences _preferences = MyThemePreferences();
  bool get isDark => _isDark;

  ModelTheme() {
    _isDark = false;
    initialize();
  }

  Future<void> initialize() async {
    await getPreferences();
  }

  void changeTheme() {
    isDark ? isDark = false : isDark = true;
    notifyListeners();
  }

  set isDark(bool value) {
    _isDark = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  Future<void> getPreferences() async {
    _isDark = await _preferences.getTheme();
    notifyListeners();
  }
}
