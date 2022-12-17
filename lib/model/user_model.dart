import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  UserModel({
    required this.name,
    required this.email,
    required this.uid,
    required this.imageUrl,
  });

  final String name;
  final String email;
  final String uid;
  final String imageUrl;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'imageUrl': imageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  factory UserModel.fromUser(User user) {
    return UserModel(
        name: user.displayName ?? '',
        email: user.email ?? '',
        uid: user.uid,
        imageUrl: user.photoURL ?? '');
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
