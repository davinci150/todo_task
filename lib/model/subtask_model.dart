import 'package:equatable/equatable.dart';

class SubtaskModel extends Equatable {
  const SubtaskModel({
    required this.text,
    required this.isDone,
    required this.createdOn,
    required this.isVisible,
    required this.id,
  });
  factory SubtaskModel.empty() {
    return SubtaskModel(
      text: '',
      isDone: false,
      createdOn: DateTime.now(),
      isVisible: true,
      id: 0,
    );
  }
  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    final createdOn = json['CreatedOn'] is int
        ? DateTime.fromMillisecondsSinceEpoch(json['CreatedOn'] as int)
        : null;
    final id = json['Id'] as int;
    final text = json['Text'] as String;
    final isDone = json['IsDone'] != null ? json['IsDone'] as bool : null;
    final isVisible =
        json['IsVisible'] != null ? json['IsVisible'] as bool : null;
    return SubtaskModel(
        createdOn: createdOn,
        id: id,
        text: text,
        isDone: isDone,
        isVisible: isVisible);
  }

  final int? id;
  final String? text;
  final bool? isDone;
  final bool? isVisible;
  final DateTime? createdOn;

  SubtaskModel copyWith(
      {String? text, bool? isDone, bool? isVisible, DateTime? createdOn}) {
    return SubtaskModel(
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

  @override
  List<Object?> get props => [
        text,
        isDone,
        createdOn,
        isVisible,
        id,
      ];
}
