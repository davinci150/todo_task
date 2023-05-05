import 'package:flutter/material.dart';

@immutable
class FolderModel {
  const FolderModel({
    required this.title,
    this.ownerUid,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) => FolderModel(
        title: json['Title'] as String,
      );

  final String title;
  final String? ownerUid;

  FolderModel copyWith({String? title, String? ownerUid}) {
    return FolderModel(
      title: title ?? this.title,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Title'] = title;
    data['OwnerUid'] = ownerUid;

    return data;
  }

  @override
  String toString() => 'FolderModel{title: $title}';

  @override
  bool operator ==(Object other) {
    if (other is FolderModel) {
      return title == other.title;
    }
    return false;
  }

  @override
  int get hashCode => title.hashCode;
}
