import 'dart:async';
import 'package:todo_task/api/birthdays_api.dart';
import 'package:todo_task/model/birthday_model.dart';
import 'package:rxdart/rxdart.dart';

import '../dialog/input_text_dialog.dart';

class BirthdaysRepository {
  BirthdaysRepository._();

  static final BirthdaysRepository instance = BirthdaysRepository._();

  BehaviorSubject<List<BirthdayModel>>? streamBirthdays;

  Stream<List<BirthdayModel>?> birthdaysStream() {
    return BirthdaysApi().birthdaysStream();
  }

  void addBirthday(TaskCreated model) {
    BirthdaysApi().addBirthday(model);
  }
}
