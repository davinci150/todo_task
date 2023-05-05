import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../model/birthday_model.dart';
import 'auth_api.dart';

@LazySingleton()
class BirthdaysApi {
  BirthdaysApi({required this.authApi});

  final AuthApi authApi;

  Stream<List<BirthdayModel>> birthdaysStream() {
    return FirebaseFirestore.instance
        .collection(authApi.getPath)
        .doc(authApi.getUid)
        .collection('birthdays')
        .snapshots()
        .map((event) {
      final List<BirthdayModel> list = [];
      event.docs.forEach((value) {
        final bd = BirthdayModel.fromJson(value.data(), value.id);

        list.add(bd);
      });

      return list;
    });
  }

  Future<List<BirthdayModel>> getBdays() async {
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
  }

  Future<void> addBirthday(BirthdayModel model) async {
    await FirebaseFirestore.instance
        .collection(authApi.getPath)
        .doc(authApi.getUid)
        .collection('birthdays')
        .doc()
        .set(model.toJson());
  }
}
