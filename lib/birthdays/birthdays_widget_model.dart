import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_task/services/notification_service.dart';
import 'package:todo_task/repository/birthdays_repository.dart';

import '../widgets/dialog/adaptive_dialog.dart';
import '../model/birthday_model.dart';

class BirthdaysWidgetModel extends ChangeNotifier {
  BirthdaysWidgetModel() {
    _setup();
  }

  List<BirthdayModel> birthdays = [];

  void _setup() {
    GetIt.I<BirthdaysRepository>().birthdaysStream().listen((event) {
      birthdays = event ?? [];
      notifyListeners();
    });
  }

  void addBirthday(BirthdayModel model) {
    GetIt.I<BirthdaysRepository>().addBirthday(model);
    //NotificationService().yearlyNotification(0, model.date!, model.text);
  }
}

class BirthdaysModelProvider extends InheritedNotifier {
  const BirthdaysModelProvider(
      {Key? key, required Widget child, required this.model})
      : super(key: key, child: child, notifier: model);

  final BirthdaysWidgetModel model;

  static BirthdaysModelProvider? watch(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BirthdaysModelProvider>();
  }

  static BirthdaysModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<BirthdaysModelProvider>()
        ?.widget;
    return widget is BirthdaysModelProvider ? widget : null;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<Listenable> oldWidget) {
    return true;
  }
}
