import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_task/model/birthday_model.dart';

import '../dialog/input_text_dialog.dart';
import '../home_page.dart';

class BirthdaysApi {
  Stream<List<BirthdayModel>> birthdaysStream() {
    return FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('birthdays')
        .doc('birthdays')
        .snapshots()
        .map((event) {
      final List<BirthdayModel> list = [];
      event.data()?.forEach((key, value) {
        list.add(BirthdayModel(name: key, birthday: DateTime.now()));
      });

      return list;
    });
  }

  void addBirthday(TaskCreated model) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('birthdays')
        .doc('birthdays')
        .update({model.text: model.date?.toIso8601String()});
  }
}
