import 'package:flutter/material.dart';

import 'main.dart';

ThemeData get darkTheme {
  // return ThemeData(
  //     fontFamily: 'Rubik-Regular',
  //     primaryColor: const Color(0xFF7165ca),
  //     cardColor: const Color(0xFF282b38),
  //     drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF2D2C31)),
  //     appBarTheme:
  //         const AppBarTheme(backgroundColor: Color(0xFF23232b), elevation: 1),
  //     brightness: Brightness.dark,
  //     scaffoldBackgroundColor: const Color(0xFF23232b),
  //     floatingActionButtonTheme: const FloatingActionButtonThemeData(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(20))),
  //         backgroundColor: Color(0xFF7165ca)));
  return ThemeData(
      primaryIconTheme: iconTheme,
      fontFamily: 'Rubik-Regular',
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              textStyle: ButtonStyleButton.allOrNull<TextStyle>(
                  TextStyle(color: Colors.white, fontSize: 14)))),
      textTheme: textTheme,
      primaryColor: const Color(0xFF7165ca),
      cardColor: const Color(0xFF282b38),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF201D2E)),
      appBarTheme:
          const AppBarTheme(backgroundColor: Color(0xFF23232b), elevation: 1),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF161421),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          backgroundColor: Color(0xFF7165ca)));
}

ThemeData get lightTheme {
  return ThemeData(
      primaryIconTheme: iconTheme,
      textTheme: textTheme,
      backgroundColor: Colors.blueGrey,
      fontFamily: 'Rubik-Regular',
      brightness: Brightness.light,
      appBarTheme:
          const AppBarTheme(backgroundColor: Colors.blueGrey, elevation: 1),
      primaryColor: Colors.blueGrey,
      iconTheme: const IconThemeData(color: Colors.black),
      scaffoldBackgroundColor: const Color(0xFFEFEFEF),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey));
}

TextTheme get textTheme {
  return TextTheme(bodyMedium: TextStyle(fontSize: isDesktop ? 16 : 20));
}

IconThemeData get iconTheme {
  return IconThemeData(size: isDesktop ? 18 : 26);
}
