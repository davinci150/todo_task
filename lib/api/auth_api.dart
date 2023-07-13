import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../dao/auth_dao.dart';
import '../model/user_model.dart';

@LazySingleton()
class AuthApi {
  AuthApi();

  final String _path = kDebugMode ? 'test' : 'tasksNew';

  String? get getUid {
    if(Platform.isMacOS){
      return 'XwPyl4RONohYU4wbvyrQtQY1hLi2';
      //return 'P0mcfYwoVSd4KOzUDz2kwhUCS7l2';
    }
    //return 'mKSkbFBTiteCnZQjVi2QzaZFF0e2';
    return FirebaseAuth.instance.currentUser?.uid;
  }

  String get getPath {
    return _path;
  }

  final googleSignInArgs = GoogleSignInArgs(
      clientId:
          '668468006082-h76emhnpea6kq2lmv043ptlq7298qdq9.apps.googleusercontent.com',
      redirectUri: //'https://localhost:59892/',
          //'https://todo-dcf3a.firebaseapp.com/__/auth/action?mode=action&oobCode=code'
          'https://todo-dcf3a.firebaseapp.com/__/auth/handler',
      // 'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler',
      //  scope: 'email',ws://127.0.0.1:56710/7f4HmGG5B0I=/ws
      scope: 'email');

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GetIt.I<AuthDao>().deleteUser();
  }

  Future<UserModel?> login(UserModel user) async {
    UserModel res = user.copyWith();

    final credinal = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: res.email, password: '123123');
    final token = credinal.user?.uid;

    res = res.copyWith(uid: token);
    return res;
  }

  Future<UserModel?> signUp(UserModel user) async {
    UserModel res = user.copyWith();

    final credinal = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: res.email, password: '123123');
    await FirebaseAuth.instance.currentUser?.updateDisplayName(user.name);
    final token = credinal.user?.uid;
    if (token != null) {
      final docUser =
          await FirebaseFirestore.instance.collection('users').doc(token).get();
      if (!docUser.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(token)
            .set(<String, dynamic>{
          'Name': res.name,
          'Email': res.email,
        });

        await FirebaseFirestore.instance
            .collection(getPath)
            .doc(token)
            .set(<String, dynamic>{});
      }

      res = res.copyWith(uid: token);
      return res;
    }
    return null;
  }

  Future<UserModel?> signInWithGoogle() async {
    final result = await DesktopWebviewAuth.signIn(googleSignInArgs);

    final credential =
        GoogleAuthProvider.credential(accessToken: result?.accessToken);
    //final credinal =
    await FirebaseAuth.instance.signInWithCredential(credential);

    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    debugPrint(firebaseUser.toString());
    if (firebaseUser != null) {
      final user = UserModel.fromUser(firebaseUser);

      return user;
    }
    return null;
  }
}
