

import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_model.dart';

class AuthDao {
  static const userKey = 'user_key';

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
    prefs.setString(userKey, model.toJson());
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(userKey);
  }
}
