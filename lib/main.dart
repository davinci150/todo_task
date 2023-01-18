import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/dao/tasks_dao.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TasksDao.instance.initialize();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyC32WB0mGBAEKSVz5ozz7_k2KdlurznicQ',
          appId: '1:668468006082:ios:2ff7f4830a135bcd79ff5b',
          messagingSenderId: '',
          projectId: 'todo-dcf3a'));

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
          theme: themeNotifier.isDark ? darkTheme : lightTheme,
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(),
        );
      }),
    );
  }
}

ThemeData get darkTheme {
  return ThemeData(
      fontFamily: 'Rubik-Regular',
      primaryColor: const Color(0xFF7165ca),
      cardColor: const Color(0xFF282b38),
      appBarTheme:
          const AppBarTheme(backgroundColor: Color(0xFF23232b), elevation: 0),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF23232b),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          backgroundColor: Color(0xFF7165ca)));
}

ThemeData get lightTheme {
  return ThemeData(
      textTheme: const TextTheme(),
      fontFamily: 'Rubik-Regular',
      brightness: Brightness.light,
      appBarTheme:
          const AppBarTheme(backgroundColor: Colors.blueGrey, elevation: 0),
      primaryColor: Colors.blueGrey,
      iconTheme: const IconThemeData(color: Colors.black),
      scaffoldBackgroundColor: const Color(0xFFEFEFEF),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey));
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
  final MyThemePreferences _preferences = MyThemePreferences();
  bool get isDark => _isDark;

  ModelTheme() {
    _isDark = false;
    initialize();
  }

  Future<void> initialize() async {
    await getPreferences();
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
