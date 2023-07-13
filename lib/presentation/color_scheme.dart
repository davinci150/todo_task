import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class ColorTheme {
  const ColorTheme({
    required this.primaryColor,
    required this.primaryTextColor,
    required this.scaffoldDesktopColor,
    required this.grayColor,
    required this.checkboxColor,
    required this.dividerColor,
    required this.logoutColor,
    required this.selectedItemSidebarColor,
    required this.sidebarIconColor,
    required this.mobileScaffoldColor,
    required this.sidebarBackgroundColor,
    required this.appBarColor,
  });

  final Color primaryColor;
  final Color primaryTextColor;
  final Color scaffoldDesktopColor;
  final Color grayColor;
  final Color checkboxColor;
  final Color dividerColor;
  final Color logoutColor;
  final Color selectedItemSidebarColor;
  final Color mobileScaffoldColor;
  final Color sidebarIconColor;
  final Color sidebarBackgroundColor;
  final Color appBarColor;
}

// LIGHT
class LightColorTheme implements ColorTheme {
  @override
  Color get checkboxColor =>AppColors.gray;// Color(0xFFC4C1CE);
  @override
  Color get dividerColor => AppColors.zambezi;

  @override
  Color get grayColor => AppColors.gray;

  @override
  Color get logoutColor => AppColors.burntSienna;

  @override
  Color get mobileScaffoldColor => AppColors.athensGray;

  @override
  Color get primaryColor => AppColors.mariner;

  @override
  Color get primaryTextColor => AppColors.danube;

  @override
  Color get scaffoldDesktopColor => AppColors.alto;

  @override
  Color get selectedItemSidebarColor => AppColors.bermudaGray;

  @override
  Color get sidebarIconColor => Colors.black;

  @override
  Color get sidebarBackgroundColor => Colors.white;

  @override
  Color get appBarColor => Colors.white;
}

// DARK
class DarkColorTheme implements ColorTheme {
  @override
  Color get checkboxColor => AppColors.jumbo;

  @override
  Color get dividerColor => AppColors.zambezi;

  @override
  Color get grayColor => AppColors.gray;

  @override
  Color get logoutColor => AppColors.alizarinCrimson;

  @override
  Color get mobileScaffoldColor => AppColors.cinder;

  @override
  Color get primaryColor => AppColors.blueMarguerite;

  @override
  Color get primaryTextColor => Colors.white;

  @override
  Color get scaffoldDesktopColor => AppColors.cinder;

  @override
  Color get selectedItemSidebarColor => AppColors.bermudaGray;

  @override
  Color get sidebarIconColor => Colors.white;

  @override
  Color get sidebarBackgroundColor => AppColors.steelGray;

  @override
  Color get appBarColor => AppColors.steelGrayLight;
}
