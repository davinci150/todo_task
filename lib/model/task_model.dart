import 'package:equatable/equatable.dart';
import 'subtask_model.dart';

class TaskModel extends Equatable {
  const TaskModel({
    required this.viewedUid,
    required this.ownerUid,
    required this.text,
    required this.subtasks,
    required this.isDone,
    required this.id,
    required this.createdOn,
    required this.isVisible,
    required this.indexInList,
    required this.notificationDate,
  });

  factory TaskModel.empty(int index) {
    return TaskModel(
      id: '',
      text: '',
      subtasks: const [],
      viewedUid: const [],
      ownerUid: '',
      notificationDate: null,
      isDone: false,
      createdOn: DateTime.now(),
      isVisible: true,
      indexInList: index,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    final text = json['Text'] as String;
    final tasks = <SubtaskModel>[];
    if (json['Tasks'] != null) {
      json['Tasks'].forEach((dynamic v) {
        final SubtaskModel model = SubtaskModel.fromJson(v as Map<String, dynamic>);
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

    return TaskModel(
      id: id,
      text: text,
      subtasks: tasks,
      isDone: isDone,
      viewedUid: viewedUid,
      ownerUid: ownerUid,
      createdOn: createdOn,
      notificationDate: notificationDate,
      isVisible: isVisible,
      indexInList: indexInList,
    );
  }

  final String id;
  final String text;
  final List<SubtaskModel> subtasks;
  final List<String> viewedUid;
  final String ownerUid;
  final bool? isDone;
  final bool? isVisible;
  final int? indexInList;
  final DateTime createdOn;
  final DateTime? notificationDate;

  TaskModel copyWith({
    String? text,
    List<SubtaskModel>? subtasks,
    bool? isDone,
    int? indexInList,
    String? ownerUid,
    List<String>? viewedUid,
    bool? isVisible,
    String? id,
    DateTime? createdOn,
    DateTime? Function()? notificationDate,
  }) {
    return TaskModel(
      viewedUid: viewedUid ?? this.viewedUid,
      ownerUid: ownerUid ?? this.ownerUid,
      id: id ?? this.id,
      text: text ?? this.text,
      notificationDate:
          notificationDate != null ? notificationDate() : this.notificationDate,
      indexInList: indexInList ?? this.indexInList,
      subtasks: subtasks ?? this.subtasks,
      createdOn: createdOn ?? this.createdOn,
      isVisible: isVisible ?? this.isVisible,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Text'] = text;
    data['OwnerUid'] = ownerUid;
    data['Tasks'] = subtasks.map((e) => e.toJson()).toList();
    data['ViewedUid'] = viewedUid.map((e) => e).toList();
    data['CreatedOn'] = createdOn.millisecondsSinceEpoch;
    data['IsDone'] = isDone;
    data['IsVisible'] = isVisible;
    data['IndexInList'] = indexInList;
    data['NotificationDate'] = notificationDate?.toIso8601String();
    return data;
  }

  @override
  String toString() =>
      'GroupModel{text: $text, tasks: $subtasks, notificationDate: $notificationDate, indexInList: $indexInList, isVisible: $isVisible, isDone: $isDone}';

  @override
  List<Object?> get props => [
        viewedUid,
        ownerUid,
        text,
        subtasks,
        isDone,
        id,
        createdOn,
        isVisible,
        indexInList,
        notificationDate,
      ];
}


