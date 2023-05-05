import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:todo_task/api/birthdays_api.dart';
import 'package:todo_task/model/birthday_model.dart';
import 'package:rxdart/rxdart.dart';

import '../widgets/dialog/adaptive_dialog.dart';

@LazySingleton()
class BirthdaysRepository {
  BirthdaysRepository({required this.birthdaysApi});

  final BirthdaysApi birthdaysApi;

  BehaviorSubject<List<BirthdayModel>>? streamBirthdays;

  Stream<List<BirthdayModel>?> birthdaysStream() {
    return birthdaysApi.birthdaysStream();
  }

  void addBirthday(BirthdayModel model) {
    birthdaysApi.addBirthday(model);
  }
}
