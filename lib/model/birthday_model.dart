import 'package:flutter/material.dart';

@immutable
class BirthdayModel {
  const BirthdayModel({
    this.uid,
    this.name,
    this.birthday,
  });

  factory BirthdayModel.fromJson(Map<String, dynamic> json, String uid) =>
      BirthdayModel(
        uid: uid,
        name: json['Name'] as String,
        birthday: DateTime.parse(json['Birthday'] as String),
      );

  final String? uid;
  final String? name;
  final DateTime? birthday;

  BirthdayModel copyWith({String? name, DateTime? birthday}) {
    return BirthdayModel(
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['Birthday'] = birthday?.toIso8601String();

    return data;
  }

  @override
  String toString() =>
      'BirthdayModel{name: $name, birthday: ${birthday?.toIso8601String()}, uid: ${uid}}';

  @override
  bool operator ==(Object other) {
    if (other is BirthdayModel) {
      return name == other.name && birthday == other.birthday;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode ^ birthday.hashCode;
}
