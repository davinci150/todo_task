import 'dart:developer';

import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../dao/auth_dao.dart';
import '../model/user_model.dart';

class AuthApi {
  final googleSignInArgs = GoogleSignInArgs(
      clientId:
          '668468006082-h76emhnpea6kq2lmv043ptlq7298qdq9.apps.googleusercontent.com',
      redirectUri: //'https://localhost:59892/',
          //'https://todo-dcf3a.firebaseapp.com/__/auth/action?mode=action&oobCode=code'
          'https://todo-dcf3a.firebaseapp.com/__/auth/handler',
      // 'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler',
      //  scope: 'email',ws://127.0.0.1:56710/7f4HmGG5B0I=/ws
      scope: 'email');

  Future<UserModel?> signUp() async {
    UserModel? user;
    try {
      final result = await DesktopWebviewAuth.signIn(googleSignInArgs);

      final credential =
          GoogleAuthProvider.credential(accessToken: result?.accessToken);
      //final credinal =
      await FirebaseAuth.instance.signInWithCredential(credential);

      User? firebaseUser = FirebaseAuth.instance.currentUser;
      print(firebaseUser.toString());
      if (firebaseUser != null) {
        user = UserModel.fromUser(firebaseUser);
        AuthDao().saveUserModel(user);
      }
    } catch (err) {
      log(err.toString());
    }
    return user;
  }
}
