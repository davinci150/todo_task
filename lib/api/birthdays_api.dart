import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../model/birthday_model.dart';
import 'auth_api.dart';

@LazySingleton()
class BirthdaysApi {
  BirthdaysApi({required this.authApi});

  final AuthApi authApi;

  Stream<List<BirthdayModel>> birthdaysStream() {
    return birthdaysRef().snapshots().map((event) {
      final List<BirthdayModel> list = [];
      event.docs.forEach((value) {
        list.add(BirthdayModel.fromJson(value.data(), value.id));
      });
      list.sort((a, b) => a.countdownDays.compareTo(b.countdownDays));
      return list;
    });
  }

/*   Future<List<BirthdayModel>> getBdays() async {
    final List<BirthdayModel> bdays = [];
    final docs = await FirebaseFirestore.instance
        .collection(authApi.getPath)
        .doc(authApi.getUid)
        .collection('birthdays')
        .get();

    docs.docs.forEach((event) {
      final bd = BirthdayModel.fromJson(event.data(), event.id);
      bdays.add(bd);
    });
    return bdays;
  } */

  Future<String> addBirthday(BirthdayModel model) async {
    final response = await birthdaysRef().add(model.toJson());
    return response.id;
  }

  Future<void> deleteBirthday(String id) async {
    await birthdaysRef().doc(id).delete();
  }

  Future<void> removeBirthday(String id) async {
    await birthdaysRef().doc(id).delete();
  }

  CollectionReference<Map<String, dynamic>> birthdaysRef() {
    return FirebaseFirestore.instance
        .collection('birthdays')
        .doc(authApi.getUid)
        .collection('birthdays');
  }
}
