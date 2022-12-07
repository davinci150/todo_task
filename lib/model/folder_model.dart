import 'package:todo_task/model/group_model.dart';

class FolderModel {
  FolderModel({
    required this.title,
    required this.tasks,
  });

  String? title;
  List<GroupModel>? tasks;

  FolderModel.fromJson(Map<String, dynamic> json) {
    title = json['Title'] as String;
    final tas = <GroupModel>[];
    if (json['Folder'] != null) {
      json['Folder'].forEach((dynamic v) {
        final GroupModel model = GroupModel.fromJson(v as Map<String, dynamic>);
        tas.add(model);
      });
    }
    tasks = tas;
  }

  FolderModel copyWith({String? title, List<GroupModel>? tasks}) {
    return FolderModel(
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Title'] = title;
    data['Folder'] = tasks?.map((e) => e.toJson()).toList();

    return data;
  }

  @override
  String toString() => 'FolderModel{title: $title, tasks: $tasks}';
}
