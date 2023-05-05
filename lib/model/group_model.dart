import 'package:flutter/material.dart';
import 'task_model.dart';

@immutable
class GroupModel {
  const GroupModel({
    required this.viewedUid,
    required this.ownerUid,
    required this.text,
    required this.tasks,
    required this.isDone,
    required this.uid,
    required this.createdOn,
    required this.isVisible,
    required this.indexInList,
    required this.notificationDate,
  });

  factory GroupModel.empty(int index) {
    return GroupModel(
      uid: '',
      text: '',
      tasks: const [],
      viewedUid: const [],
      ownerUid: '',
      notificationDate: null,
      isDone: false,
      createdOn: DateTime.now(),
      isVisible: true,
      indexInList: index,
    );
  }

  factory GroupModel.fromJson(Map<String, dynamic> json, String uid) {
    final text = json['Text'] as String;
    final tasks = <TaskModel>[];
    if (json['Tasks'] != null) {
      json['Tasks'].forEach((dynamic v) {
        final TaskModel model = TaskModel.fromJson(v as Map<String, dynamic>);
        tasks.add(model);
      });
    }
    final viewedUid = <String>[];
    if (json['ViewedUid'] != null) {
      json['ViewedUid'].forEach((dynamic v) {
        viewedUid.add(v as String);
      });
    }

    final createdOn =
        DateTime.fromMillisecondsSinceEpoch(json['CreatedOn'] as int);
    final isDone = json['IsDone'] != null ? json['IsDone'] as bool : null;
    final isVisible =
        json['IsVisible'] != null ? json['IsVisible'] as bool : null;
    final notificationDate = json['NotificationDate'] is String
        ? DateTime.parse(json['NotificationDate'] as String)
        : null;
    final indexInList = json['IndexInList'] as int;
    final ownerUid = json['OwnerUid'] as String;

    return GroupModel(
      uid: uid,
      text: text,
      tasks: tasks,
      isDone: isDone,
      viewedUid: viewedUid,
      ownerUid: ownerUid,
      createdOn: createdOn,
      notificationDate: notificationDate,
      isVisible: isVisible,
      indexInList: indexInList,
    );
  }

  final String uid;
  final String text;
  final List<TaskModel> tasks;
  final List<String> viewedUid;
  final String ownerUid;
  final bool? isDone;
  final bool? isVisible;
  final int? indexInList;
  final DateTime createdOn;
  final DateTime? notificationDate;

  GroupModel copyWith({
    String? text,
    List<TaskModel>? tasks,
    bool? isDone,
    int? indexInList,
    String? ownerUid,
    List<String>? viewedUid,
    bool? isVisible,
    String? uid,
    DateTime? createdOn,
    DateTime? Function()? notificationDate,
  }) {
    return GroupModel(
      viewedUid: viewedUid ?? this.viewedUid,
      ownerUid: ownerUid ?? this.ownerUid,
      uid: uid ?? this.uid,
      text: text ?? this.text,
      notificationDate:
          notificationDate != null ? notificationDate() : this.notificationDate,
      indexInList: indexInList ?? this.indexInList,
      tasks: tasks ?? this.tasks,
      createdOn: createdOn ?? this.createdOn,
      isVisible: isVisible ?? this.isVisible,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Text'] = text;
    data['OwnerUid'] = ownerUid;
    data['Tasks'] = tasks.map((e) => e.toJson()).toList();
    data['ViewedUid'] = viewedUid.map((e) => e).toList();
    data['CreatedOn'] = createdOn.millisecondsSinceEpoch;
    data['IsDone'] = isDone;
    data['IsVisible'] = isVisible;
    data['IndexInList'] = indexInList;
    data['NotificationDate'] = notificationDate?.toIso8601String();
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (other is GroupModel) {
      return text == other.text &&
          isDone == other.isDone &&
          indexInList == other.indexInList &&
          notificationDate == other.notificationDate &&
          isVisible == other.isVisible;
    }
    return false;
  }

  @override
  String toString() =>
      'GroupModel{text: $text, tasks: $tasks, notificationDate: $notificationDate, indexInList: $indexInList, isVisible: $isVisible, isDone: $isDone}';

  @override
  int get hashCode =>
      text.hashCode ^
      isDone.hashCode ^
      indexInList.hashCode ^
      notificationDate.hashCode ^
      isVisible.hashCode;
}

class Members {
  Members({this.uid});

  factory Members.fromJson(Map<String, dynamic> json) {
    return Members(uid: json['Uid'] as String?);
  }

  final String? uid;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Uid'] = uid;

    return data;
  }
}

class GroupWrapper {
  GroupWrapper({
    required this.groups,
    required this.members,
  });

  final List<GroupModel> groups;
  final List<Members> members;
}
