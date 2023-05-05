import 'package:flutter/material.dart';

import '../main.dart';

/* ThemeData get darkTheme {
  return ThemeData(
      dialogTheme: darkDialogTheme,
      extensions: [
        MyColors(
          sidebarSelectedItemColor: const Color(0xFF798EA7).withOpacity(0.1),
          sidebarIconThemeData:
              const IconThemeData(color: Colors.white, size: 24),
          cardTextStyle: const TextStyle(color: Colors.amber),
        )
      ],
      primaryIconTheme: darkIconTheme,
      backgroundColor: const Color(0xFF201D2E),
      popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          //color: const Color(0xFF24324A),
          textStyle: const TextStyle(color: Colors.white)),
      fontFamily: 'Rubik-Regular',
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              textStyle: ButtonStyleButton.allOrNull<TextStyle>(
                  const TextStyle(color: Colors.white, fontSize: 14)))),
      textTheme: darkTextTheme,
      primaryColor: const Color(0xFF7165ca),
      cardColor: const Color(0xFF272437),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF201D2E)),
      appBarTheme:
          const AppBarTheme(backgroundColor: Color(0xFF201D2E), elevation: 1),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF161421),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          backgroundColor: Color(0xFF7165ca)));
}

ThemeData get lightTheme {
  return ThemeData(
      dialogTheme: lightDialogTheme,
      extensions: [
        MyColors(
          sidebarSelectedItemColor: const Color(0xFF2E6FD7).withOpacity(0.05),
          sidebarIconThemeData:
              const IconThemeData(color: Colors.black, size: 24),
          cardTextStyle: const TextStyle(color: Colors.red),
        )
      ],
      primaryIconTheme: lightIconTheme,
      popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: const Color(0xFF24324A),
          textStyle: const TextStyle(color: Colors.white)),
      textTheme: lightTextTheme,
      backgroundColor: const Color(0xFFF8F9FD),
      drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
      fontFamily: 'Rubik-Regular',
      brightness: Brightness.light,
      cardColor: const Color(0xFF273953),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 22),
          centerTitle: true),
      primaryColor: const Color(0xFF2E6FD7),
      //   drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF201D2E)),
      iconTheme: const IconThemeData(color: Colors.black),
      scaffoldBackgroundColor:
          const Color(0xFFF1F1F3), // const Color(0xFF24324A),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF2E6FD7)));
}

DialogTheme get lightDialogTheme =>
    const DialogTheme(backgroundColor: Colors.white);

DialogTheme get darkDialogTheme =>
    const DialogTheme(backgroundColor: Color(0xFF201D2E));

TextTheme get darkTextTheme {
  return TextTheme(
    headlineLarge: const TextStyle(color: Colors.white, fontSize: 24),
    bodyMedium: TextStyle(fontSize: isDesktop ? 14 : 20, color: Colors.white),
    bodySmall: TextStyle(fontSize: isDesktop ? 12 : 20, color: Colors.white),
  );
}

TextTheme get lightTextTheme {
  return TextTheme(
    headlineLarge: const TextStyle(color: Colors.blue, fontSize: 24),
    bodyMedium: TextStyle(fontSize: isDesktop ? 14 : 20, color: Colors.black),
    bodySmall: TextStyle(fontSize: isDesktop ? 12 : 20, color: Colors.black),
  );
}

IconThemeData get lightIconTheme {
  return IconThemeData(size: isDesktop ? 18 : 24, color: Colors.white);
}

IconThemeData get darkIconTheme {
  return IconThemeData(size: isDesktop ? 18 : 24);
}

class CustomTheme {
  static MyColors of(BuildContext context) {
    return Theme.of(context).extension<MyColors>()!;
  }
}

class MyColors extends ThemeExtension<MyColors> {
  const MyColors({
    required this.cardTextStyle,
    required this.sidebarIconThemeData,
    required this.sidebarSelectedItemColor,
  });

  final TextStyle? cardTextStyle;
  final Color? sidebarSelectedItemColor;
  final IconThemeData? sidebarIconThemeData;

  @override
  ThemeExtension<MyColors> copyWith({
    TextStyle? cardTextStyle,
    IconThemeData? sidebarIconThemeData,
    Color? sidebarSelectedItemColor,
  }) {
    return MyColors(
      sidebarIconThemeData: sidebarIconThemeData ?? this.sidebarIconThemeData,
      sidebarSelectedItemColor:
          sidebarSelectedItemColor ?? this.sidebarSelectedItemColor,
      cardTextStyle: cardTextStyle ?? this.cardTextStyle,
    );
  }

  @override
  ThemeExtension<MyColors> lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) {
      return this;
    }
    return MyColors(
      sidebarIconThemeData: IconThemeData.lerp(
          sidebarIconThemeData, other.sidebarIconThemeData, t),
      cardTextStyle: TextStyle.lerp(cardTextStyle, other.cardTextStyle, t),
      sidebarSelectedItemColor: Color.lerp(
          sidebarSelectedItemColor, other.sidebarSelectedItemColor, t),
    );
  }
}
 */