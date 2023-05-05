import 'package:flutter/material.dart';

import '../birthdays/birthdays.dart';
import '../home/preview_page.dart';
import '../model/folder_model.dart';
import '../settings/settings_page.dart';
import '../tasks_page/tasks_page.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  late Widget page;
  if (settings.name == 'tasks_page') {
    page = TasksPage(folder: settings.arguments as FolderModel);
  } else if (settings.name == 'birthdays') {
    page = const BirthdaysPage();
  } else if (settings.name == 'settings') {
    page = const SettingsPage();
  } else {
    page = const PreviewPage();
  }

  return CustomNavRoute<dynamic>(builder: (ctx) => page, settings: settings);
}

class CustomNavRoute<T> extends MaterialPageRoute<T> {
  CustomNavRoute({WidgetBuilder? builder, RouteSettings? settings})
      : super(builder: builder!, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // if (settings.isInitialRoute) return child;
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    final tween =
        Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: curve));

    return FadeTransition(
      opacity: animation.drive(tween),
      child: child,
    );
  }
}
