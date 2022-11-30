import 'package:todo_task/model/task_model.dart';

class GroupModel {
  GroupModel({
    required this.text,
    required this.tasks,
  });

  String? text;
  List<TaskModel>? tasks;

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
  }

  GroupModel copyWith({String? text, List<TaskModel>? tasks}) {
    return GroupModel(
      text: text ?? this.text,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Text'] = text;
    data['Tasks'] = tasks?.map((e) => e.toJson()).toList();

    return data;
  }

  @override
  String toString() => '{text: $text, tasks: $tasks}';
}
