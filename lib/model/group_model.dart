import 'package:todo_task/model/task_model.dart';

class GroupModel {
  const GroupModel({
    required this.text,
    required this.tasks,
    required this.isDone,
    required this.createdOn,
    required this.isVisible,
    required this.indexInList,
    required this.notificationDate,
  });

  final String? text;
  final List<TaskModel>? tasks;
  final bool? isDone;
  final bool? isVisible;
  final int? indexInList;
  final DateTime? createdOn;
  final DateTime? notificationDate;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final text = json['Text'] as String;
    final tas = <TaskModel>[];
    if (json['Tasks'] != null) {
      json['Tasks'].forEach((dynamic v) {
        final TaskModel model = TaskModel.fromJson(v as Map<String, dynamic>);
        tas.add(model);
      });
    }
    final tasks = tas;
    final createdOn = json['CreatedOn'] is int
        ? DateTime.fromMillisecondsSinceEpoch(json['CreatedOn'] as int)
        : null;
    final isDone = json['IsDone'] != null ? json['IsDone'] as bool : null;
    final isVisible =
        json['IsVisible'] != null ? json['IsVisible'] as bool : null;
    final notificationDate = json['NotificationDate'] is String
        ? DateTime.parse(json['NotificationDate'])
        : null;
    final indexInList = json['IndexInList'] as int;
    return GroupModel(
      text: text,
      tasks: tasks,
      isDone: isDone,
      createdOn: createdOn,
      notificationDate: notificationDate,
      isVisible: isVisible,
      indexInList: indexInList,
    );
  }

  factory GroupModel.empty(int index) {
    return GroupModel(
      text: '',
      tasks: [],
      notificationDate: null,
      isDone: false,
      createdOn: DateTime.now(),
      isVisible: true,
      indexInList: index,
    );
  }

  GroupModel copyWith({
    String? text,
    List<TaskModel>? tasks,
    bool? isDone,
    int? indexInList,
    bool? isVisible,
    DateTime? createdOn,
    DateTime? notificationDate,
  }) {
    return GroupModel(
      text: text ?? this.text,
      notificationDate: notificationDate ?? this.notificationDate,
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
    data['Tasks'] = tasks?.map((e) => e.toJson()).toList();
    data['CreatedOn'] = createdOn?.millisecondsSinceEpoch;
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
