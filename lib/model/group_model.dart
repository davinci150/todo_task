import 'package:todo_task/model/task_model.dart';

class GroupModel {
  GroupModel({
    required this.text,
    required this.tasks,
    required this.isDone,
    required this.createdOn,
    required this.isVisible,
  });

  String? text;
  List<TaskModel>? tasks;
  bool? isDone;
  bool? isVisible;
  DateTime? createdOn;

  GroupModel.fromJson(Map<String, dynamic> json) {
    text = json['Text'] as String;
    final tas = <TaskModel>[];
    if (json['Tasks'] != null) {
      json['Tasks'].forEach((dynamic v) {
        final TaskModel model = TaskModel.fromJson(v as Map<String, dynamic>);
        tas.add(model);
      });
    }
    tasks = tas;
    createdOn = json['CreatedOn'] is int
        ? DateTime.fromMillisecondsSinceEpoch(json['CreatedOn'] as int)
        : null;
    isDone = json['IsDone'] != null ? json['IsDone'] as bool : null;
    isVisible = json['IsVisible'] != null ? json['IsVisible'] as bool : null;
  }

  GroupModel copyWith(
      {String? text,
      List<TaskModel>? tasks,
      bool? isDone,
      bool? isVisible,
      DateTime? createdOn}) {
    return GroupModel(
      text: text ?? this.text,
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
    return data;
  }

  @override
  String toString() =>
      'GroupModel{text: $text, tasks: $tasks, isVisible: $isVisible, isDone: $isDone}';
}
