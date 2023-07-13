import 'package:equatable/equatable.dart';

class FolderModel extends Equatable {
  const FolderModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json, String id) =>
      FolderModel(
        id: id,
        name: json['Name'] as String,
        createdBy: json['CreatedBy'] as String,
        members: (json['Members'] as List<dynamic>).cast<String>(),
      );

  final String id;
  final String name;
  final String createdBy;
  final List<String> members;

  FolderModel copyWith(
      {String? name, String? createdBy, String? id, List<String>? members}) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['CreatedBy'] = createdBy;
    data['Members'] = members;

    return data;
  }

  @override
  List<Object> get props => [name, createdBy, id, members];
}
