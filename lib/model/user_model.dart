import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  UserModel({
    required this.name,
    required this.email,
    required this.uid,
    required this.imageUrl,
  });

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory UserModel.fromUser(User user) {
    return UserModel(
        name: user.displayName ?? '',
        email: user.email ?? '',
        uid: user.uid,
        imageUrl: user.photoURL ?? '');
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }

  final String name;
  final String email;
  final String uid;
  final String imageUrl;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'uid': uid,
      'imageUrl': imageUrl,
    };
  }

  String toJson() => json.encode(toMap());

  UserModel copyWith({
    String? name,
    String? email,
    String? uid,
    String? imageUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
