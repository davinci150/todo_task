import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_model.dart';

@LazySingleton()
class AuthDao {
  static const userKey = 'user_key0';

  Future<UserModel?> getLoggedUser() async {
    UserModel? user;
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(userKey);
    if (userJson != null) {
      user = UserModel.fromJson(userJson);
    }
    return user;
  }

  Future<void> saveUserModel(UserModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, model.toJson());
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
  }
}
