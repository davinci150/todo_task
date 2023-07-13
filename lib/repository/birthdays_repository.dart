import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../api/birthdays_api.dart';
import '../model/birthday_model.dart';
import '../services/notification_service.dart';

@LazySingleton()
class BirthdaysRepository {
  BirthdaysRepository({required this.birthdaysApi});

  final BirthdaysApi birthdaysApi;

  BehaviorSubject<List<BirthdayModel>>? streamBirthdays;

  Stream<List<BirthdayModel>?> birthdaysStream() {
    return birthdaysApi.birthdaysStream();
  }

  Future<void> addBirthday(BirthdayModel model) async {
    final String id = await birthdaysApi.addBirthday(model);

    await NotificationService()
        .yearlyNotification(id.hashCode, model.birthday!, model.name!);
  }

  Future<void> deleteBirthday(String id) async {
    await birthdaysApi.deleteBirthday(id);

    await NotificationService().cancelNotification(id.hashCode);
  }
}
