class TaskModel {
  TaskModel({
    required this.text,
    required this.isDone,
    required this.createdOn,
    required this.isVisible,
    required this.id,
  });

  int? id;
  String? text;
  bool? isDone;
  bool? isVisible;
  DateTime? createdOn;

  TaskModel.fromJson(Map<String, dynamic> json) {
    createdOn = json['CreatedOn'] is int
        ? DateTime.fromMillisecondsSinceEpoch(json['CreatedOn'] as int)
        : null;
    id = json['Id'] as int;
    text = json['Text'] as String;
    isDone = json['IsDone'] != null ? json['IsDone'] as bool : null;
    isVisible = json['IsVisible'] != null ? json['IsVisible'] as bool : null;
  }

  TaskModel copyWith(
      {String? text, bool? isDone, bool? isVisible, DateTime? createdOn}) {
    return TaskModel(
      id: id,
      createdOn: createdOn ?? this.createdOn,
      isVisible: isVisible ?? this.isVisible,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Text'] = text;
    data['CreatedOn'] = createdOn?.millisecondsSinceEpoch;
    data['IsDone'] = isDone;
    data['IsVisible'] = isVisible;

    return data;
  }

  @override
  String toString() => 'TaskModel{text: $text, isDone: $isDone}';
}
